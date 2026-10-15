/**
 * Centralized API & Authentication Service
 * Connects to ASP.NET Core Web API (default http://localhost:5012)
 */
class ApiService {
    constructor() {
        this.baseUrl = localStorage.getItem('ride_api_base_url') || 'http://localhost:5012';
        this.tokenKey = 'ride_admin_jwt_token';
        this.isDemoMode = localStorage.getItem('ride_demo_mode') === 'true';
        this.isOnline = false;
        this.statusListeners = [];
    }

    getBaseUrl() {
        return this.baseUrl;
    }

    setBaseUrl(url) {
        this.baseUrl = url.replace(/\/+$/, '');
        localStorage.setItem('ride_api_base_url', this.baseUrl);
        this.checkHealth();
    }

    getToken() {
        return localStorage.getItem(this.tokenKey);
    }

    setToken(token) {
        if (token) {
            localStorage.setItem(this.tokenKey, token);
        } else {
            localStorage.removeItem(this.tokenKey);
        }
    }

    setDemoMode(enabled) {
        this.isDemoMode = !!enabled;
        localStorage.setItem('ride_demo_mode', this.isDemoMode ? 'true' : 'false');
        this.notifyStatusListeners();
    }

    onStatusChange(listener) {
        this.statusListeners.push(listener);
    }

    notifyStatusListeners() {
        this.statusListeners.forEach(fn => fn({
            isOnline: this.isOnline,
            isDemoMode: this.isDemoMode,
            baseUrl: this.baseUrl,
            hasToken: !!this.getToken()
        }));
    }

    async checkHealth() {
        try {
            // Ping a public GET endpoint (/api/Payment) that requires no authentication
            const url = `${this.baseUrl.replace(/\/+$/, '')}/api/Payment`;
            const res = await fetch(url, {
                method: 'GET',
                headers: { 'Accept': 'application/json' }
            });
            // 200 OK means server is running and accessible
            this.isOnline = res.ok || res.status === 200;
        } catch (err) {
            this.isOnline = false;
        }
        this.notifyStatusListeners();
        return this.isOnline;
    }

    async login(username, password) {
        if (this.isDemoMode) {
            const fakeToken = "demo_jwt_token_" + Date.now();
            this.setToken(fakeToken);
            this.notifyStatusListeners();
            return { token: fakeToken, isDemo: true };
        }

        try {
            // Always clear any existing token prior to login
            this.setToken(null);

            const cleanUser = (username != null ? String(username) : '').trim();
            const cleanPass = (password != null ? String(password) : '').trim();

            const url = `${this.baseUrl.replace(/\/+$/, '')}/api/Admin/login`;

            // Explicitly build headers WITHOUT an Authorization header
            const headers = {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            };
            delete headers['Authorization'];
            delete headers['authorization'];

            // Match ASP.NET Core LoginRequest model properties (Username, Password)
            // as well as camelCase for universal serializer compatibility
            const payload = {
                Username: cleanUser,
                Password: cleanPass,
                username: cleanUser,
                password: cleanPass
            };

            const response = await fetch(url, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                let errorMsg = 'Invalid username or password';
                try {
                    const errorData = await response.json();
                    errorMsg = errorData.message || errorData.title || errorMsg;
                } catch {
                    try {
                        const errTxt = await response.text();
                        if (errTxt) errorMsg = errTxt;
                    } catch {}
                }
                throw new Error(errorMsg);
            }

            const data = await response.json();
            if (data && data.token) {
                this.setToken(data.token);
                this.isOnline = true;
                this.notifyStatusListeners();
            }
            return data;
        } catch (error) {
            console.warn("Live login failed, error:", error);
            throw error;
        }
    }

    logout() {
        this.setToken(null);
        this.notifyStatusListeners();
    }

    async request(endpoint, options = {}) {
        if (this.isDemoMode) {
            return null; // Mock layer handles this
        }

        const url = `${this.baseUrl}${endpoint.startsWith('/') ? endpoint : '/' + endpoint}`;
        const headers = {
            'Content-Type': 'application/json',
            ...(options.headers || {})
        };

        const token = this.getToken();
        // Never attach Authorization header to login endpoint
        if (token && !endpoint.includes('/api/Admin/login')) {
            headers['Authorization'] = `Bearer ${token}`;
        }

        try {
            const res = await fetch(url, { ...options, headers });

            if (res.status === 401) {
                console.warn("Session expired or unauthorized for:", endpoint);
                // Attempt auto-login if credentials available, or clear token
                this.setToken(null);
                this.notifyStatusListeners();
                throw new Error("UNAUTHORIZED");
            }

            if (!res.ok) {
                const errText = await res.text();
                throw new Error(`API Error [${res.status}]: ${errText || res.statusText}`);
            }

            this.isOnline = true;
            this.notifyStatusListeners();

            // Handle empty responses (like 204 No Content or empty strings)
            const text = await res.text();
            return text ? JSON.parse(text) : {};
        } catch (err) {
            if (err.message !== "UNAUTHORIZED") {
                this.isOnline = false;
                this.notifyStatusListeners();
            }
            throw err;
        }
    }

    // ==========================================
    // 1. OVERVIEW & TELEMETRY
    // ==========================================
    async getOverviewMetrics() {
        if (this.isDemoMode) {
            return MockData.overviewStats;
        }
        try {
            // Aggregate from live backend endpoints
            const [riders, customers, rides, payments, ratings] = await Promise.all([
                this.request('/api/Rider').catch(() => []),
                this.request('/api/Customer').catch(() => []),
                this.request('/api/Ride/monitoring').catch(() => []),
                this.request('/api/Payment').catch(() => []),
                this.request('/api/Rating').catch(() => [])
            ]);

            const safeList = (data) => Array.isArray(data) ? data : [];
            const rList = safeList(riders);
            const cList = safeList(customers);
            const tripList = safeList(rides);
            const pList = safeList(payments);
            const rateList = safeList(ratings);

            const activeRides = tripList.filter(r => r && r.status === 1).length;
            const pendingApprovals = rList.filter(r => r && (r.approvalStatus === 'Pending' || r.documentApprovalStatus === 'Pending')).length;
            const onlineRiders = rList.filter(r => r && r.isActive && r.approvalStatus === 'Approved').length;
            const revenueToday = pList.filter(p => p && p.paymentStatus === 'Completed').reduce((sum, p) => sum + (Number(p.amount) || 0), 0);
            const avgRating = rateList.length > 0 
                ? (rateList.reduce((sum, r) => sum + (Number(r.ratingValue) || 5), 0) / rateList.length).toFixed(1)
                : 5.0;

            return {
                totalRides: tripList.length,
                activeRides,
                onlineRiders,
                pendingApprovals,
                totalCustomers: cList.length,
                revenueToday,
                avgRating: Number(avgRating),
                completedToday: tripList.filter(r => r && r.status === 2).length
            };
        } catch (err) {
            console.warn("Using mock stats due to API failure", err);
            return MockData.overviewStats;
        }
    }

    // ==========================================
    // 2. CUSTOMER MANAGEMENT
    // ==========================================
    async getCustomers() {
        if (this.isDemoMode) return MockData.customers;
        try {
            const list = await this.request('/api/Customer');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.customers : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.customers;
            throw err;
        }
    }

    async getCustomer(id) {
        return this.request(`/api/Customer/${id}`);
    }

    async createCustomer(data) {
        return this.request('/api/Customer', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateCustomer(id, data) {
        return this.request(`/api/Customer/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteCustomer(id) {
        return this.request(`/api/Customer/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 3. RIDER MANAGEMENT & APPROVALS
    // ==========================================
    async getRiders() {
        if (this.isDemoMode) return MockData.riders;
        try {
            const list = await this.request('/api/Rider');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.riders : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.riders;
            throw err;
        }
    }

    async getRider(id) {
        return this.request(`/api/Rider/${id}`);
    }

    async createRider(data) {
        return this.request('/api/Rider', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateRider(id, data) {
        return this.request(`/api/Rider/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteRider(id) {
        return this.request(`/api/Rider/${id}`, {
            method: 'DELETE'
        });
    }

    async approveRider(id) {
        return this.request(`/api/Rider/approve/${id}`, {
            method: 'PUT'
        });
    }

    async rejectRider(id) {
        return this.request(`/api/Rider/reject/${id}`, {
            method: 'PUT'
        });
    }

    // ==========================================
    // 4. DOCUMENT APPROVAL
    // ==========================================
    async approveDocument(id) {
        return this.request(`/api/Rider/document-approve/${id}`, {
            method: 'PUT'
        });
    }

    async rejectDocument(id) {
        return this.request(`/api/Rider/document-reject/${id}`, {
            method: 'PUT'
        });
    }

    // ==========================================
    // 5. RIDE MONITORING
    // ==========================================
    async getRides() {
        if (this.isDemoMode) return MockData.rides;
        try {
            const list = await this.request('/api/Ride/monitoring');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.rides : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.rides;
            throw err;
        }
    }

    async getRide(id) {
        return this.request(`/api/Ride/${id}`);
    }

    async createRide(data) {
        return this.request('/api/Ride', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateRide(id, data) {
        return this.request(`/api/Ride/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteRide(id) {
        return this.request(`/api/Ride/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 6. PRICING & SURGE CONFIGURATION
    // ==========================================
    async getPricing() {
        if (this.isDemoMode) return MockData.pricing;
        try {
            const list = await this.request('/api/Pricing');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.pricing : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.pricing;
            throw err;
        }
    }

    async createPricing(data) {
        return this.request('/api/Pricing', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updatePricing(id, data) {
        return this.request(`/api/Pricing/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deletePricing(id) {
        return this.request(`/api/Pricing/${id}`, {
            method: 'DELETE'
        });
    }

    async getSurge() {
        if (this.isDemoMode) return MockData.surge;
        try {
            const list = await this.request('/api/Surge');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.surge : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.surge;
            throw err;
        }
    }

    async createSurge(data) {
        return this.request('/api/Surge', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateSurge(id, data) {
        return this.request(`/api/Surge/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteSurge(id) {
        return this.request(`/api/Surge/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 7. PLATFORM SETTINGS
    // ==========================================
    async getSettings() {
        if (this.isDemoMode) return MockData.settings;
        try {
            const list = await this.request('/api/PlatformSettings');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.settings : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.settings;
            throw err;
        }
    }

    async createSetting(data) {
        return this.request('/api/PlatformSettings', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateSetting(id, data) {
        return this.request(`/api/PlatformSettings/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteSetting(id) {
        return this.request(`/api/PlatformSettings/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 8. PAYMENT MONITORING
    // ==========================================
    async getPayments() {
        if (this.isDemoMode) return MockData.payments;
        try {
            const list = await this.request('/api/Payment');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.payments : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.payments;
            throw err;
        }
    }

    async createPayment(data) {
        return this.request('/api/Payment', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updatePayment(id, data) {
        return this.request(`/api/Payment/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deletePayment(id) {
        return this.request(`/api/Payment/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 9. REPORTS & OPERATIONAL DATA
    // ==========================================
    async getReports() {
        if (this.isDemoMode) return MockData.reports;
        try {
            const list = await this.request('/api/Report');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.reports : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.reports;
            throw err;
        }
    }

    async createReport(data) {
        return this.request('/api/Report', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async deleteReport(id) {
        return this.request(`/api/Report/${id}`, {
            method: 'DELETE'
        });
    }

    async getOperationalData() {
        if (this.isDemoMode) return MockData.operationalData;
        try {
            const list = await this.request('/api/OperationalData');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.operationalData : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.operationalData;
            throw err;
        }
    }

    async createOperationalData(data) {
        return this.request('/api/OperationalData', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async updateOperationalData(id, data) {
        return this.request(`/api/OperationalData/${id}`, {
            method: 'PUT',
            body: JSON.stringify({ id, ...data })
        });
    }

    async deleteOperationalData(id) {
        return this.request(`/api/OperationalData/${id}`, {
            method: 'DELETE'
        });
    }

    // ==========================================
    // 10. RATINGS, FEEDBACK & AUDIT LOGS
    // ==========================================
    async getRatings() {
        if (this.isDemoMode) return MockData.ratings;
        try {
            const list = await this.request('/api/Rating');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.ratings : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.ratings;
            throw err;
        }
    }

    async createRating(data) {
        return this.request('/api/Rating', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async deleteRating(id) {
        return this.request(`/api/Rating/${id}`, {
            method: 'DELETE'
        });
    }

    async getAuditLogs() {
        if (this.isDemoMode) return MockData.auditLogs;
        try {
            const list = await this.request('/api/AuditLog');
            return (list && list.length > 0) ? list : (this.isDemoMode ? MockData.auditLogs : list);
        } catch (err) {
            if (this.isDemoMode) return MockData.auditLogs;
            throw err;
        }
    }

    async createAuditLog(data) {
        return this.request('/api/AuditLog', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async deleteAuditLog(id) {
        return this.request(`/api/AuditLog/${id}`, {
            method: 'DELETE'
        });
    }
}

// Global API instance
window.api = new ApiService();
