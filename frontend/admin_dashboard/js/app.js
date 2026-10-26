/**
 * Main Application Controller for Nikhy Ride Management Admin Dashboard
 * Manages UI routing, section renderers, modals, search/filters, and API triggers.
 */

// ============================================================
// RESILIENT NULL-SAFE DOM HELPERS
// ============================================================
const safeElem = (id) => document.getElementById(id);
const setText = (id, text) => {
    const el = document.getElementById(id);
    if (el) el.textContent = (text != null) ? text : '';
};
const setValue = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.value = (val != null) ? val : '';
};
const setChecked = (id, checked) => {
    const el = document.getElementById(id);
    if (el) el.checked = !!checked;
};
const getValue = (id, defaultVal = '') => {
    const el = document.getElementById(id);
    return el ? el.value : defaultVal;
};
const getChecked = (id, defaultVal = false) => {
    const el = document.getElementById(id);
    return el ? el.checked : defaultVal;
};

class AdminApp {
    constructor() {
        this.currentSection = 'overview';
        this.charts = {};
        this.cachedData = {
            customers: [],
            riders: [],
            rides: [],
            pricing: [],
            surge: [],
            settings: [],
            payments: [],
            reports: [],
            operationalData: [],
            ratings: [],
            auditLogs: []
        };
    }

    async init() {
        this.bindEvents();
        this.setupStatusWatcher();

        // Attempt initial authentication handshake
        await this.authenticateInitialSession();

        // Initial route navigation
        this.navigateTo('overview');
    }

    setupStatusWatcher() {
        window.api.onStatusChange((status) => {
            const pill = document.getElementById('backendStatusPill');
            const demoBtn = document.getElementById('demoModeToggle');
            const urlDisplay = document.getElementById('apiUrlDisplay');

            if (urlDisplay) urlDisplay.textContent = status.baseUrl;

            if (status.isDemoMode) {
                if (pill) {
                    pill.innerHTML = `<span class="status-dot demo"></span> Demo / Preview Mode`;
                    pill.className = "backend-pill warning";
                }
                if (demoBtn) {
                    demoBtn.innerHTML = `<i class="fas fa-toggle-on"></i> Demo Mode ON`;
                    demoBtn.className = "header-btn demo-mode-badge";
                }
            } else if (status.isOnline) {
                if (pill) {
                    pill.innerHTML = `<span class="status-dot online"></span> Live API: ${status.baseUrl.replace('http://', '').replace('https://', '')}`;
                    pill.className = "backend-pill success";
                }
                if (demoBtn) {
                    demoBtn.innerHTML = `<i class="fas fa-toggle-off"></i> Live Mode`;
                    demoBtn.className = "header-btn";
                }
            } else {
                if (pill) {
                    pill.innerHTML = `<span class="status-dot offline"></span> API Offline`;
                    pill.className = "backend-pill danger";
                }
                if (demoBtn) {
                    demoBtn.innerHTML = `<i class="fas fa-plug"></i> Switch to Demo`;
                    demoBtn.className = "header-btn";
                }
            }
        });

        // Trigger health check
        window.api.checkHealth();
    }

    async authenticateInitialSession() {
        if (window.api.isDemoMode) return;

        // Verify if existing token is valid
        const existingToken = window.api.getToken();
        if (existingToken) {
            try {
                // Test if token is accepted by an authorized endpoint
                await window.api.request('/api/Customer');
                return; // Token valid!
            } catch (err) {
                console.warn('Stored JWT token was expired or rejected. Clearing and re-authenticating...', err);
                window.api.setToken(null);
            }
        }

        // Auto-login with default admin credentials
        try {
            await window.api.login('admin', '1234');
            this.showToast('Connected to Live API & Logged in as Admin', 'success');
        } catch (err) {
            console.warn('Admin login could not authenticate with backend:', err);
            if (!window.api.isOnline) {
                window.api.setDemoMode(true);
                this.showToast('Backend offline. Activated Demo Preview Mode.', 'warning');
            }
        }
    }

    bindEvents() {
        // Sidebar Navigation
        document.querySelectorAll('.nav-link[data-target]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const target = link.getAttribute('data-target');
                this.navigateTo(target);

                // Close mobile sidebar if open
                document.querySelector('.sidebar')?.classList.remove('open');
            });
        });

        // Mobile Menu Toggle
        document.getElementById('mobileMenuBtn')?.addEventListener('click', () => {
            document.querySelector('.sidebar')?.classList.toggle('open');
        });

        // Demo Mode Toggle Button
        document.getElementById('demoModeToggle')?.addEventListener('click', () => {
            const newMode = !window.api.isDemoMode;
            window.api.setDemoMode(newMode);
            this.showToast(`Switched to ${newMode ? 'Demo Preview Mode' : 'Live API Mode'}`, 'info');
            this.refreshCurrentSection();
        });

        // Manual Refresh Button
        document.getElementById('refreshBtn')?.addEventListener('click', () => {
            this.refreshCurrentSection();
            this.showToast('Refreshing section data...', 'info');
        });

        // Configure API Server Modal
        document.getElementById('serverConfigBtn')?.addEventListener('click', () => {
            const currentUrl = window.api.getBaseUrl();
            const input = prompt('Enter ASP.NET Core Backend API URL:', currentUrl);
            if (input && input.trim()) {
                window.api.setBaseUrl(input.trim());
                this.showToast(`Backend URL updated to: ${input.trim()}`, 'success');
                this.refreshCurrentSection();
            }
        });

        // User Profile & Manual Login Trigger
        document.getElementById('userProfileBtn')?.addEventListener('click', () => {
            this.openModal('loginModal');
        });

        // Login Modal Submit Handler
        document.getElementById('loginSubmitBtn')?.addEventListener('click', async () => {
            const user = getValue('loginUsername', 'admin');
            const pass = getValue('loginPassword', '1234');
            const submitBtn = safeElem('loginSubmitBtn');
            const alertBox = safeElem('loginAlertBox');

            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Logging in...';
            }
            if (alertBox) alertBox.style.display = 'none';

            try {
                await window.api.login(user, pass);
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Log In';
                }
                this.closeModal('loginModal');
                this.showToast(`Logged in successfully as ${user}`, 'success');
                this.refreshCurrentSection();
            } catch (err) {
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Log In';
                }
                if (alertBox) {
                    alertBox.style.display = 'block';
                    alertBox.style.background = 'rgba(239, 68, 68, 0.15)';
                    alertBox.style.color = '#ef4444';
                    alertBox.style.border = '1px solid rgba(239, 68, 68, 0.3)';
                    alertBox.textContent = err.message || 'Login failed. Invalid username or password.';
                }
            }
        });

        // Theme Toggle
        document.getElementById('themeToggleBtn')?.addEventListener('click', () => {
            const currentTheme = document.body.getAttribute('data-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';
            document.body.setAttribute('data-theme', newTheme);
            localStorage.setItem('ride_theme', newTheme);
        });

        // Restore saved theme
        const savedTheme = localStorage.getItem('ride_theme') || 'dark';
        document.body.setAttribute('data-theme', savedTheme);
    }

    navigateTo(sectionId) {
        this.currentSection = sectionId;

        // Update nav links
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.toggle('active', link.getAttribute('data-target') === sectionId);
        });

        // Update sections
        document.querySelectorAll('.dashboard-section').forEach(sec => {
            sec.classList.remove('active');
        });
        const activeSection = document.getElementById(`section-${sectionId}`);
        if (activeSection) {
            activeSection.classList.add('active');
        }

        // Update Page Title
        const titleEl = document.getElementById('pageTitle');
        if (titleEl) {
            const navLink = document.querySelector(`.nav-link[data-target="${sectionId}"]`);
            titleEl.textContent = navLink ? navLink.innerText.trim() : 'Dashboard';
        }

        // Load section data
        this.loadSectionData(sectionId);
    }

    refreshCurrentSection() {
        this.loadSectionData(this.currentSection);
    }

    async loadSectionData(sectionId) {
        try {
            switch (sectionId) {
                case 'overview':
                    await this.renderOverview();
                    break;
                case 'customers':
                    await this.renderCustomers();
                    break;
                case 'riders':
                    await this.renderRiders();
                    break;
                case 'documents':
                    await this.renderDocuments();
                    break;
                case 'rides':
                    await this.renderRides();
                    break;
                case 'pricing':
                    await this.renderPricing();
                    break;
                case 'settings':
                    await this.renderSettings();
                    break;
                case 'payments':
                    await this.renderPayments();
                    break;
                case 'reports':
                    await this.renderReports();
                    break;
                case 'audit':
                    await this.renderAuditLogs();
                    break;
            }
        } catch (err) {
            console.error(`Error loading section ${sectionId}:`, err);
            this.showToast(`Error loading ${sectionId}: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 1. OVERVIEW
    // ============================================================
    async renderOverview() {
        const metrics = (await window.api.getOverviewMetrics()) || {};

        // Update Stats DOM (100% null-safe)
        setText('statTotalRides', metrics.totalRides || 0);
        setText('statActiveRides', metrics.activeRides || 0);
        setText('statOnlineRiders', metrics.onlineRiders || 0);
        setText('statPendingApprovals', metrics.pendingApprovals || 0);
        setText('statCustomers', metrics.totalCustomers || 0);
        setText('statRevenueToday', `₹${(metrics.revenueToday || 0).toLocaleString('en-IN')}`);
        setText('statAvgRating', `${metrics.avgRating || 5.0} ★`);

        // Render Overview Charts
        this.renderOverviewCharts(metrics);

        // Render Recent Audit summary in Overview
        const audit = await window.api.getAuditLogs().catch(() => []);
        const recentActivityEl = document.getElementById('recentActivityFeed');
        if (recentActivityEl) {
            const auditList = Array.isArray(audit) ? audit : [];
            if (auditList.length === 0) {
                recentActivityEl.innerHTML = `<div style="padding:1rem;color:var(--text-muted);">No recent administrative activity logged.</div>`;
            } else {
                recentActivityEl.innerHTML = auditList.slice(0, 5).map(a => `
                    <div style="display:flex;align-items:flex-start;gap:0.75rem;padding:0.75rem 0;border-bottom:1px solid var(--border-subtle);">
                        <div class="avatar" style="width:28px;height:28px;font-size:0.75rem;background:var(--bg-surface-elevated);color:var(--brand-accent);">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div style="flex:1;">
                            <div style="font-weight:600;font-size:0.85rem;color:var(--text-primary);">${a.action || 'ACTION'} - ${a.entityName || 'Entity'} #${a.entityId || ''}</div>
                            <div style="font-size:0.8rem;color:var(--text-secondary);">${a.description || ('Action performed by ' + (a.performedBy || 'Admin'))}</div>
                            <div style="font-size:0.7rem;color:var(--text-muted);">${new Date(a.performedAt || Date.now()).toLocaleTimeString()}</div>
                        </div>
                    </div>
                `).join('');
            }
        }
    }

    renderOverviewCharts(metrics) {
        if (typeof Chart === 'undefined') {
            console.warn('Chart.js not loaded');
            return;
        }
        // Chart 1: Revenue & Volume Trends
        const trendCtx = document.getElementById('overviewTrendChart');
        if (trendCtx) {
            if (this.charts.trend) this.charts.trend.destroy();
            this.charts.trend = new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'],
                    datasets: [{
                        label: 'Gross GMV (₹)',
                        data: [54000, 62000, 58000, 71000, 69000, 89000, metrics.revenueToday || 84520],
                        borderColor: '#d4af37',
                        backgroundColor: 'rgba(212, 175, 55, 0.14)',
                        fill: true,
                        tension: 0.4
                    }, {
                        label: 'Trips Completed',
                        data: [210, 245, 230, 290, 275, 340, metrics.completedToday || 320],
                        borderColor: '#10b981',
                        borderDash: [5, 5],
                        tension: 0.4,
                        yAxisID: 'y1'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'top' } },
                    scales: {
                        y: { beginAtZero: true },
                        y1: { position: 'right', grid: { drawOnChartArea: false }, beginAtZero: true }
                    }
                }
            });
        }

        // Chart 2: Ride Distribution
        const distCtx = document.getElementById('overviewDistributionChart');
        if (distCtx) {
            if (this.charts.distribution) this.charts.distribution.destroy();
            this.charts.distribution = new Chart(distCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Completed', 'Ongoing', 'Scheduled', 'Cancelled'],
                    datasets: [{
                        data: [72, metrics.activeRides || 8, 12, 8],
                        backgroundColor: ['#10b981', '#d4af37', '#f59e0b', '#ef4444'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom' } }
                }
            });
        }
    }

    // ============================================================
    // 2. CUSTOMER MANAGEMENT
    // ============================================================
    async renderCustomers() {
        const customers = await window.api.getCustomers();
        this.cachedData.customers = customers || [];
        this.filterAndDisplayCustomers();
    }

    filterAndDisplayCustomers() {
        const query = (document.getElementById('customerSearchInput')?.value || '').toLowerCase();
        const statusFilter = document.getElementById('customerStatusFilter')?.value || 'all';

        const filtered = this.cachedData.customers.filter(c => {
            const matchesQuery = !query || 
                (c.name && c.name.toLowerCase().includes(query)) ||
                (c.email && c.email.toLowerCase().includes(query)) ||
                (c.phone && c.phone.includes(query));
            const matchesStatus = statusFilter === 'all' || 
                (statusFilter === 'active' && c.isActive) ||
                (statusFilter === 'inactive' && !c.isActive);
            return matchesQuery && matchesStatus;
        });

        const tbody = document.getElementById('customersTableBody');
        if (!tbody) return;

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;padding:2rem;color:var(--text-muted);">No customers found matching criteria.</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(c => `
            <tr>
                <td>#CUST-${c.id}</td>
                <td>
                    <div style="font-weight:600;color:var(--text-primary);">${c.name}</div>
                </td>
                <td>${c.email}</td>
                <td>${c.phone}</td>
                <td>
                    <span class="badge ${c.isActive ? 'badge-success' : 'badge-danger'}">
                        ${c.isActive ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <div style="display:flex;gap:0.35rem;">
                        <button class="btn btn-secondary btn-icon" title="Edit Customer" onclick="app.editCustomer(${c.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-icon" title="Delete Customer" onclick="app.deleteCustomer(${c.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    openAddCustomerModal() {
        setText('customerModalTitle', 'Add New Customer');
        setValue('customerId', '');
        setValue('customerName', '');
        setValue('customerEmail', '');
        setValue('customerPhone', '');
        setChecked('customerIsActive', true);
        this.openModal('customerModal');
    }

    editCustomer(id) {
        const c = this.cachedData.customers.find(item => item.id === id);
        if (!c) return;

        setText('customerModalTitle', `Edit Customer #CUST-${c.id}`);
        setValue('customerId', c.id);
        setValue('customerName', c.name);
        setValue('customerEmail', c.email);
        setValue('customerPhone', c.phone);
        setChecked('customerIsActive', c.isActive);
        this.openModal('customerModal');
    }

    async saveCustomer() {
        const id = getValue('customerId');
        const name = getValue('customerName').trim();
        const email = getValue('customerEmail').trim();
        const phone = getValue('customerPhone').trim();
        const isActive = getChecked('customerIsActive', true);

        if (!name || !email || !phone) {
            this.showToast('Please fill in Name, Email, and Phone', 'warning');
            return;
        }

        try {
            if (id) {
                await window.api.updateCustomer(Number(id), { name, email, phone, isActive });
                this.showToast('Customer updated successfully', 'success');
            } else {
                await window.api.createCustomer({ name, email, phone, isActive });
                this.showToast('New customer registered successfully', 'success');
            }
            this.closeModal('customerModal');
            await this.renderCustomers();
        } catch (err) {
            this.showToast(`Operation failed: ${err.message}`, 'error');
        }
    }

    async deleteCustomer(id) {
        if (!confirm(`Are you sure you want to delete Customer #CUST-${id}?`)) return;
        try {
            await window.api.deleteCustomer(id);
            this.showToast('Customer deleted successfully', 'success');
            await this.renderCustomers();
        } catch (err) {
            this.showToast(`Delete failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 3. RIDER MANAGEMENT & APPROVALS
    // ============================================================
    async renderRiders() {
        const riders = await window.api.getRiders();
        this.cachedData.riders = riders || [];
        this.filterAndDisplayRiders();
    }

    filterAndDisplayRiders() {
        const query = (document.getElementById('riderSearchInput')?.value || '').toLowerCase();
        const statusFilter = document.getElementById('riderStatusFilter')?.value || 'all';

        const filtered = this.cachedData.riders.filter(r => {
            const matchesQuery = !query ||
                (r.name && r.name.toLowerCase().includes(query)) ||
                (r.vehicleNumber && r.vehicleNumber.toLowerCase().includes(query)) ||
                (r.licenseNumber && r.licenseNumber.toLowerCase().includes(query)) ||
                (r.phone && r.phone.includes(query));
            const matchesStatus = statusFilter === 'all' || (r.approvalStatus || 'Pending').toLowerCase() === statusFilter.toLowerCase();
            return matchesQuery && matchesStatus;
        });

        const tbody = document.getElementById('ridersTableBody');
        if (!tbody) return;

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--text-muted);">No riders found matching criteria.</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(r => {
            const approval = r.approvalStatus || 'Pending';
            let badgeClass = 'badge-warning';
            if (approval === 'Approved') badgeClass = 'badge-success';
            if (approval === 'Rejected') badgeClass = 'badge-danger';

            return `
            <tr>
                <td>#RIDER-${r.id}</td>
                <td>
                    <div style="font-weight:600;color:var(--text-primary);">${r.name}</div>
                    <div style="font-size:0.75rem;color:var(--text-muted);">${r.email} | ${r.phone}</div>
                </td>
                <td>
                    <span style="font-family:monospace;background:var(--bg-base);padding:2px 6px;border-radius:4px;border:1px solid var(--border-subtle);">
                        ${r.vehicleNumber || 'N/A'}
                    </span>
                </td>
                <td>
                    <span style="font-family:monospace;font-size:0.8rem;color:var(--text-secondary);">
                        ${r.licenseNumber || 'N/A'}
                    </span>
                </td>
                <td>
                    <span class="badge ${badgeClass}">${approval}</span>
                </td>
                <td>
                    <span class="badge ${r.isActive ? 'badge-success' : 'badge-danger'}">
                        ${r.isActive ? 'Active' : 'Inactive'}
                    </span>
                </td>
                <td>
                    <div style="display:flex;gap:0.35rem;align-items:center;">
                        ${approval !== 'Approved' ? `
                            <button class="btn btn-success btn-sm" title="Approve Rider" onclick="app.approveRiderAction(${r.id})">
                                <i class="fas fa-check"></i> Approve
                            </button>
                        ` : ''}
                        ${approval !== 'Rejected' ? `
                            <button class="btn btn-danger btn-sm" title="Reject Rider" onclick="app.rejectRiderAction(${r.id})">
                                <i class="fas fa-times"></i> Reject
                            </button>
                        ` : ''}
                        <button class="btn btn-secondary btn-icon" title="Edit Rider" onclick="app.editRider(${r.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-secondary btn-icon" title="Delete Rider" onclick="app.deleteRiderAction(${r.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
            `;
        }).join('');
    }

    async approveRiderAction(id) {
        try {
            await window.api.approveRider(id);
            this.showToast(`Rider #RIDER-${id} Approved`, 'success');
            await this.renderRiders();
        } catch (err) {
            this.showToast(`Approval failed: ${err.message}`, 'error');
        }
    }

    async rejectRiderAction(id) {
        try {
            await window.api.rejectRider(id);
            this.showToast(`Rider #RIDER-${id} Rejected`, 'warning');
            await this.renderRiders();
        } catch (err) {
            this.showToast(`Rejection failed: ${err.message}`, 'error');
        }
    }

    openAddRiderModal() {
        setText('riderModalTitle', 'Register New Rider');
        setValue('riderId', '');
        setValue('riderName', '');
        setValue('riderEmail', '');
        setValue('riderPhone', '');
        setValue('riderVehicleNumber', '');
        setValue('riderLicenseNumber', '');
        setValue('riderApprovalStatus', 'Pending');
        setChecked('riderIsActive', true);
        this.openModal('riderModal');
    }

    editRider(id) {
        const r = this.cachedData.riders.find(item => item.id === id);
        if (!r) return;

        setText('riderModalTitle', `Edit Rider #RIDER-${r.id}`);
        setValue('riderId', r.id);
        setValue('riderName', r.name);
        setValue('riderEmail', r.email);
        setValue('riderPhone', r.phone);
        setValue('riderVehicleNumber', r.vehicleNumber || '');
        setValue('riderLicenseNumber', r.licenseNumber || '');
        setValue('riderApprovalStatus', r.approvalStatus || 'Pending');
        setChecked('riderIsActive', r.isActive);
        this.openModal('riderModal');
    }

    async saveRider() {
        const id = getValue('riderId');
        const name = getValue('riderName').trim();
        const email = getValue('riderEmail').trim();
        const phone = getValue('riderPhone').trim();
        const vehicleNumber = getValue('riderVehicleNumber').trim();
        const licenseNumber = getValue('riderLicenseNumber').trim();
        const approvalStatus = getValue('riderApprovalStatus', 'Pending');
        const isActive = getChecked('riderIsActive', true);

        if (!name || !email || !phone) {
            this.showToast('Please fill in Name, Email, and Phone', 'warning');
            return;
        }

        try {
            if (id) {
                await window.api.updateRider(Number(id), {
                    name, email, phone, vehicleNumber, licenseNumber, approvalStatus, isActive
                });
                this.showToast('Rider updated successfully', 'success');
            } else {
                await window.api.createRider({
                    name, email, phone, vehicleNumber, licenseNumber, approvalStatus, isActive,
                    documentApprovalStatus: 'Pending'
                });
                this.showToast('New rider added successfully', 'success');
            }
            this.closeModal('riderModal');
            await this.renderRiders();
        } catch (err) {
            this.showToast(`Operation failed: ${err.message}`, 'error');
        }
    }

    async deleteRiderAction(id) {
        if (!confirm(`Are you sure you want to delete Rider #RIDER-${id}?`)) return;
        try {
            await window.api.deleteRider(id);
            this.showToast('Rider deleted successfully', 'success');
            await this.renderRiders();
        } catch (err) {
            this.showToast(`Delete failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 4. DOCUMENT APPROVAL
    // ============================================================
    async renderDocuments() {
        const riders = await window.api.getRiders();
        this.cachedData.riders = riders || [];

        const pendingList = this.cachedData.riders;
        const container = document.getElementById('documentQueueGrid');
        if (!container) return;

        if (pendingList.length === 0) {
            container.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:3rem;color:var(--text-muted);">No documents pending verification.</div>`;
            return;
        }

        container.innerHTML = pendingList.map(r => {
            const docStatus = r.documentApprovalStatus || 'Pending';
            let badgeClass = 'badge-warning';
            if (docStatus === 'Approved') badgeClass = 'badge-success';
            if (docStatus === 'Rejected') badgeClass = 'badge-danger';

            return `
            <div class="card-panel" style="padding:1.25rem;display:flex;flex-direction:column;gap:1rem;">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                    <div>
                        <div style="font-weight:700;font-size:1.05rem;color:var(--text-primary);">${r.name}</div>
                        <div style="font-size:0.8rem;color:var(--text-secondary);">${r.email} | ${r.phone}</div>
                    </div>
                    <span class="badge ${badgeClass}">${docStatus}</span>
                </div>

                <div style="background:var(--bg-base);padding:1rem;border-radius:var(--radius-sm);border:1px solid var(--border-subtle);display:flex;flex-direction:column;gap:0.5rem;">
                    <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                        <span style="color:var(--text-muted);">Vehicle Registration:</span>
                        <strong style="font-family:monospace;color:var(--text-primary);">${r.vehicleNumber || 'Not submitted'}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                        <span style="color:var(--text-muted);">Driver License:</span>
                        <strong style="font-family:monospace;color:var(--text-primary);">${r.licenseNumber || 'Not submitted'}</strong>
                    </div>
                    <div style="display:flex;justify-content:space-between;font-size:0.85rem;">
                        <span style="color:var(--text-muted);">Account Status:</span>
                        <span>${r.approvalStatus || 'Pending'}</span>
                    </div>
                </div>

                <div style="display:flex;gap:0.75rem;margin-top:auto;">
                    <button class="btn btn-success" style="flex:1;" onclick="app.approveDocAction(${r.id})">
                        <i class="fas fa-check-circle"></i> Approve Docs
                    </button>
                    <button class="btn btn-danger" style="flex:1;" onclick="app.rejectDocAction(${r.id})">
                        <i class="fas fa-times-circle"></i> Reject Docs
                    </button>
                </div>
            </div>
            `;
        }).join('');
    }

    async approveDocAction(id) {
        try {
            await window.api.approveDocument(id);
            this.showToast(`Document Approved for Rider #${id}`, 'success');
            await this.renderDocuments();
        } catch (err) {
            this.showToast(`Approval failed: ${err.message}`, 'error');
        }
    }

    async rejectDocAction(id) {
        try {
            await window.api.rejectDocument(id);
            this.showToast(`Document Rejected for Rider #${id}`, 'warning');
            await this.renderDocuments();
        } catch (err) {
            this.showToast(`Rejection failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 5. RIDE MONITORING
    // ============================================================
    async renderRides() {
        const rides = await window.api.getRides();
        this.cachedData.rides = rides || [];
        this.filterAndDisplayRides();
    }

    filterAndDisplayRides() {
        const query = (document.getElementById('rideSearchInput')?.value || '').toLowerCase();
        const statusFilter = document.getElementById('rideStatusFilter')?.value || 'all';

        const filtered = this.cachedData.rides.filter(r => {
            const matchesQuery = !query ||
                (r.pickupLocation && r.pickupLocation.toLowerCase().includes(query)) ||
                (r.dropLocation && r.dropLocation.toLowerCase().includes(query)) ||
                String(r.id).includes(query);
            const matchesStatus = statusFilter === 'all' || String(r.status) === statusFilter;
            return matchesQuery && matchesStatus;
        });

        const tbody = document.getElementById('ridesTableBody');
        if (!tbody) return;

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--text-muted);">No rides found matching filters.</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(r => {
            // Status: 0=Scheduled, 1=In Progress, 2=Completed, 3=Cancelled
            const statusMap = {
                0: { label: 'Scheduled', badge: 'badge-info' },
                1: { label: 'In Progress', badge: 'badge-warning' },
                2: { label: 'Completed', badge: 'badge-success' },
                3: { label: 'Cancelled', badge: 'badge-danger' }
            };
            const currentStatus = statusMap[r.status] || { label: 'Unknown', badge: 'badge-neutral' };

            return `
            <tr>
                <td>#RIDE-${r.id}</td>
                <td>
                    <div style="font-weight:600;color:var(--text-primary);"><i class="fas fa-map-marker-alt" style="color:var(--brand-accent);"></i> ${r.pickupLocation}</div>
                    <div style="font-size:0.8rem;color:var(--text-secondary);margin-top:2px;"><i class="fas fa-flag-checkered" style="color:var(--status-danger);"></i> ${r.dropLocation}</div>
                </td>
                <td>
                    <div style="font-size:0.85rem;">${new Date(r.rideTime || Date.now()).toLocaleString()}</div>
                </td>
                <td>${r.availableSeats} Seats</td>
                <td>
                    <strong style="color:var(--text-primary);">₹${r.price}</strong>
                </td>
                <td>
                    <span class="badge ${currentStatus.badge}">${currentStatus.label}</span>
                </td>
                <td>
                    <div style="display:flex;gap:0.35rem;">
                        <button class="btn btn-secondary btn-icon" title="Edit Ride" onclick="app.editRide(${r.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-icon" title="Cancel/Delete Ride" onclick="app.deleteRideAction(${r.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
            `;
        }).join('');
    }

    openCreateRideModal() {
        setText('rideModalTitle', 'Create New Ride');
        setValue('rideId', '');
        setValue('ridePickup', '');
        setValue('rideDrop', '');
        setValue('rideTime', new Date().toISOString().slice(0, 16));
        setValue('rideSeats', '4');
        setValue('ridePrice', '150');
        setValue('rideStatus', '0');
        this.openModal('rideModal');
    }

    editRide(id) {
        const r = this.cachedData.rides.find(item => item.id === id);
        if (!r) return;

        setText('rideModalTitle', `Edit Ride #RIDE-${r.id}`);
        setValue('rideId', r.id);
        setValue('ridePickup', r.pickupLocation);
        setValue('rideDrop', r.dropLocation);
        setValue('rideTime', new Date(r.rideTime).toISOString().slice(0, 16));
        setValue('rideSeats', r.availableSeats);
        setValue('ridePrice', r.price);
        setValue('rideStatus', r.status);
        this.openModal('rideModal');
    }

    async saveRide() {
        const id = getValue('rideId');
        const pickupLocation = getValue('ridePickup').trim();
        const dropLocation = getValue('rideDrop').trim();
        const rideTime = new Date(getValue('rideTime') || Date.now()).toISOString();
        const availableSeats = Number(getValue('rideSeats', '4'));
        const price = Number(getValue('ridePrice', '150'));
        const status = Number(getValue('rideStatus', '0'));

        if (!pickupLocation || !dropLocation) {
            this.showToast('Please provide pickup and drop locations', 'warning');
            return;
        }

        try {
            if (id) {
                await window.api.updateRide(Number(id), {
                    id: Number(id), pickupLocation, dropLocation, rideTime, availableSeats, price, status
                });
                this.showToast('Ride updated successfully', 'success');
            } else {
                await window.api.createRide({
                    pickupLocation, dropLocation, rideTime, availableSeats, price, status
                });
                this.showToast('New ride scheduled successfully', 'success');
            }
            this.closeModal('rideModal');
            await this.renderRides();
        } catch (err) {
            this.showToast(`Ride save failed: ${err.message}`, 'error');
        }
    }

    async deleteRideAction(id) {
        if (!confirm(`Are you sure you want to remove Ride #RIDE-${id}?`)) return;
        try {
            await window.api.deleteRide(id);
            this.showToast('Ride removed successfully', 'success');
            await this.renderRides();
        } catch (err) {
            this.showToast(`Delete failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 6. PRICING & SURGE CONFIGURATION
    // ============================================================
    async renderPricing() {
        const [pricing, surge] = await Promise.all([
            window.api.getPricing().catch(() => []),
            window.api.getSurge().catch(() => [])
        ]);

        this.cachedData.pricing = pricing || [];
        this.cachedData.surge = surge || [];

        // Render Base Pricing Rule
        const activeRule = this.cachedData.pricing.find(p => p.isActive) || this.cachedData.pricing[0] || {};
        setValue('pricingBaseFare', activeRule.baseFare || 50);
        setValue('pricingPerKmFare', activeRule.perKilometreFare || 14);
        setValue('pricingTimeFare', activeRule.timeFare || 1.5);
        setValue('pricingMinimumFare', activeRule.minimumFare || 70);
        setValue('pricingPlatformFee', activeRule.platformFee || 15);
        setValue('pricingRuleId', activeRule.id || '');

        // Render Surge Table
        const tbody = document.getElementById('surgeTableBody');
        if (tbody) {
            if (this.cachedData.surge.length === 0) {
                tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:2rem;color:var(--text-muted);">No surge multiplier areas configured.</td></tr>`;
            } else {
                tbody.innerHTML = this.cachedData.surge.map(s => `
                    <tr>
                        <td>#SURGE-${s.id}</td>
                        <td><strong>${s.area}</strong></td>
                        <td>
                            <span class="badge ${s.surgeMultiplier > 1.2 ? 'badge-warning' : 'badge-neutral'}" style="font-size:0.85rem;">
                                ${s.surgeMultiplier}x Multiplier
                            </span>
                        </td>
                        <td>
                            <span class="badge ${s.isActive ? 'badge-success' : 'badge-danger'}">
                                ${s.isActive ? 'Active' : 'Disabled'}
                            </span>
                        </td>
                        <td>
                            <div style="display:flex;gap:0.35rem;">
                                <button class="btn btn-secondary btn-icon" title="Edit Surge" onclick="app.editSurge(${s.id})">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-danger btn-icon" title="Deactivate Surge" onclick="app.deleteSurgeAction(${s.id})">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                `).join('');
            }
        }
    }

    async saveBasePricing() {
        const id = getValue('pricingRuleId');
        const baseFare = Number(getValue('pricingBaseFare', '50'));
        const perKilometreFare = Number(getValue('pricingPerKmFare', '14'));
        const timeFare = Number(getValue('pricingTimeFare', '1.5'));
        const minimumFare = Number(getValue('pricingMinimumFare', '70'));
        const platformFee = Number(getValue('pricingPlatformFee', '15'));

        try {
            if (id) {
                await window.api.updatePricing(Number(id), {
                    id: Number(id), baseFare, perKilometreFare, timeFare, minimumFare, platformFee, isActive: true
                });
            } else {
                await window.api.createPricing({
                    baseFare, perKilometreFare, timeFare, minimumFare, platformFee, isActive: true
                });
            }
            this.showToast('Base fare rules updated successfully', 'success');
            await this.renderPricing();
        } catch (err) {
            this.showToast(`Fare update failed: ${err.message}`, 'error');
        }
    }

    openAddSurgeModal() {
        setText('surgeModalTitle', 'Add Surge Area');
        setValue('surgeId', '');
        setValue('surgeArea', '');
        setValue('surgeMultiplier', '1.5');
        setText('surgeMultiplierVal', '1.5x');
        setChecked('surgeIsActive', true);
        this.openModal('surgeModal');
    }

    editSurge(id) {
        const s = this.cachedData.surge.find(item => item.id === id);
        if (!s) return;

        setText('surgeModalTitle', `Edit Surge: ${s.area}`);
        setValue('surgeId', s.id);
        setValue('surgeArea', s.area);
        setValue('surgeMultiplier', s.surgeMultiplier);
        setText('surgeMultiplierVal', `${s.surgeMultiplier}x`);
        setChecked('surgeIsActive', s.isActive);
        this.openModal('surgeModal');
    }

    async saveSurge() {
        const id = getValue('surgeId');
        const area = getValue('surgeArea').trim();
        const surgeMultiplier = Number(getValue('surgeMultiplier', '1.5'));
        const isActive = getChecked('surgeIsActive', true);

        if (!area) {
            this.showToast('Please specify an area name', 'warning');
            return;
        }

        try {
            if (id) {
                await window.api.updateSurge(Number(id), { id: Number(id), area, surgeMultiplier, isActive });
                this.showToast('Surge configuration updated', 'success');
            } else {
                await window.api.createSurge({ area, surgeMultiplier, isActive });
                this.showToast('Surge area registered successfully', 'success');
            }
            this.closeModal('surgeModal');
            await this.renderPricing();
        } catch (err) {
            this.showToast(`Surge save failed: ${err.message}`, 'error');
        }
    }

    async deleteSurgeAction(id) {
        if (!confirm('Deactivate this surge area?')) return;
        try {
            await window.api.deleteSurge(id);
            this.showToast('Surge area deactivated', 'success');
            await this.renderPricing();
        } catch (err) {
            this.showToast(`Deactivate failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 7. PLATFORM SETTINGS
    // ============================================================
    async renderSettings() {
        const settings = await window.api.getSettings();
        this.cachedData.settings = settings || [];

        const tbody = document.getElementById('settingsTableBody');
        if (!tbody) return;

        if (this.cachedData.settings.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:2rem;color:var(--text-muted);">No system settings registered.</td></tr>`;
            return;
        }

        tbody.innerHTML = this.cachedData.settings.map(s => `
            <tr>
                <td>#SET-${s.id}</td>
                <td>
                    <strong style="font-family:monospace;color:var(--brand-accent);">${s.key}</strong>
                </td>
                <td>
                    <span style="font-family:monospace;background:var(--bg-base);padding:2px 8px;border-radius:4px;border:1px solid var(--border-subtle);">
                        ${s.value}
                    </span>
                </td>
                <td>
                    <span class="badge ${s.isActive ? 'badge-success' : 'badge-danger'}">
                        ${s.isActive ? 'Active' : 'Disabled'}
                    </span>
                </td>
                <td>
                    <div style="display:flex;gap:0.35rem;">
                        <button class="btn btn-secondary btn-icon" title="Edit Setting" onclick="app.editSetting(${s.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-danger btn-icon" title="Deactivate" onclick="app.deleteSettingAction(${s.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    openAddSettingModal() {
        setText('settingModalTitle', 'Add Platform Parameter');
        setValue('settingId', '');
        setValue('settingKey', '');
        setValue('settingValue', '');
        setChecked('settingIsActive', true);
        this.openModal('settingModal');
    }

    editSetting(id) {
        const s = this.cachedData.settings.find(item => item.id === id);
        if (!s) return;

        setText('settingModalTitle', `Edit Setting: ${s.key}`);
        setValue('settingId', s.id);
        setValue('settingKey', s.key);
        setValue('settingValue', s.value);
        setChecked('settingIsActive', s.isActive);
        this.openModal('settingModal');
    }

    async saveSetting() {
        const id = getValue('settingId');
        const key = getValue('settingKey').trim();
        const value = getValue('settingValue').trim();
        const isActive = getChecked('settingIsActive', true);

        if (!key || !value) {
            this.showToast('Please specify both key and value', 'warning');
            return;
        }

        try {
            if (id) {
                await window.api.updateSetting(Number(id), { id: Number(id), key, value, isActive });
                this.showToast('Platform setting updated', 'success');
            } else {
                await window.api.createSetting({ key, value, isActive });
                this.showToast('Setting created successfully', 'success');
            }
            this.closeModal('settingModal');
            await this.renderSettings();
        } catch (err) {
            this.showToast(`Save failed: ${err.message}`, 'error');
        }
    }

    async deleteSettingAction(id) {
        if (!confirm('Deactivate this platform parameter?')) return;
        try {
            await window.api.deleteSetting(id);
            this.showToast('Setting deactivated', 'success');
            await this.renderSettings();
        } catch (err) {
            this.showToast(`Deactivate failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 8. PAYMENT MONITORING
    // ============================================================
    async renderPayments() {
        const payments = await window.api.getPayments();
        this.cachedData.payments = payments || [];
        this.filterAndDisplayPayments();
    }

    filterAndDisplayPayments() {
        const query = (document.getElementById('paymentSearchInput')?.value || '').toLowerCase();
        const statusFilter = document.getElementById('paymentStatusFilter')?.value || 'all';

        const filtered = this.cachedData.payments.filter(p => {
            const matchesQuery = !query ||
                (p.transactionId && p.transactionId.toLowerCase().includes(query)) ||
                String(p.rideId).includes(query);
            const matchesStatus = statusFilter === 'all' || (p.paymentStatus || '').toLowerCase() === statusFilter.toLowerCase();
            return matchesQuery && matchesStatus;
        });

        const tbody = document.getElementById('paymentsTableBody');
        if (!tbody) return;

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--text-muted);">No payment records found.</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(p => {
            const status = p.paymentStatus || 'Pending';
            let badgeClass = 'badge-warning';
            if (status === 'Completed') badgeClass = 'badge-success';
            if (status === 'Failed') badgeClass = 'badge-danger';

            return `
            <tr>
                <td>#PAY-${p.id}</td>
                <td>
                    <span style="font-family:monospace;color:var(--brand-primary);">#RIDE-${p.rideId}</span>
                </td>
                <td>
                    <strong style="font-size:0.95rem;color:var(--text-primary);">₹${Number(p.amount).toFixed(2)}</strong>
                </td>
                <td>${p.paymentMethod}</td>
                <td>
                    <span style="font-family:monospace;font-size:0.8rem;color:var(--text-secondary);">${p.transactionId || 'PENDING'}</span>
                </td>
                <td>
                    <span class="badge ${badgeClass}">${status}</span>
                </td>
                <td>
                    <div style="font-size:0.8rem;color:var(--text-muted);">${new Date(p.paymentDate || Date.now()).toLocaleString()}</div>
                </td>
            </tr>
            `;
        }).join('');
    }

    openRecordPaymentModal() {
        setValue('paymentRideId', '');
        setValue('paymentAmount', '');
        setValue('paymentMethod', 'UPI / GooglePay');
        setValue('paymentStatus', 'Completed');
        setValue('paymentTxnId', `TXN_${Date.now().toString().slice(-6)}`);
        this.openModal('paymentModal');
    }

    async savePayment() {
        const rideId = Number(getValue('paymentRideId', '0'));
        const amount = Number(getValue('paymentAmount', '0'));
        const paymentMethod = getValue('paymentMethod', 'UPI / GooglePay');
        const paymentStatus = getValue('paymentStatus', 'Completed');
        const transactionId = getValue('paymentTxnId').trim();

        if (!rideId || !amount) {
            this.showToast('Please provide valid Ride ID and Amount', 'warning');
            return;
        }

        try {
            await window.api.createPayment({
                rideId, amount, paymentMethod, paymentStatus, transactionId, paymentDate: new Date().toISOString()
            });
            this.showToast('Payment transaction recorded', 'success');
            this.closeModal('paymentModal');
            await this.renderPayments();
        } catch (err) {
            this.showToast(`Record payment failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // 9. REPORTS & OPERATIONAL DATA
    // ============================================================
    async renderReports() {
        const [reports, opData] = await Promise.all([
            window.api.getReports().catch(() => []),
            window.api.getOperationalData().catch(() => [])
        ]);

        this.cachedData.reports = reports || [];
        this.cachedData.operationalData = opData || [];

        // Operational Telemetry Grid
        const opGrid = document.getElementById('operationalMetricsGrid');
        if (opGrid) {
            opGrid.innerHTML = this.cachedData.operationalData.map(m => `
                <div class="stat-card accent">
                    <div class="stat-header">
                        <span>${m.metricName}</span>
                        <i class="fas fa-chart-line stat-icon"></i>
                    </div>
                    <div class="stat-value" style="font-size:1.5rem;">${m.value}</div>
                    <div class="stat-footer">${m.description}</div>
                </div>
            `).join('');
        }

        // Reports Table
        const tbody = document.getElementById('reportsTableBody');
        if (tbody) {
            if (this.cachedData.reports.length === 0) {
                tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;padding:2rem;color:var(--text-muted);">No reports generated yet.</td></tr>`;
            } else {
                tbody.innerHTML = this.cachedData.reports.map(r => `
                    <tr>
                        <td>#REP-${r.id}</td>
                        <td><strong>${r.reportType}</strong></td>
                        <td>${r.description}</td>
                        <td>
                            <div style="font-family:monospace;font-size:0.75rem;max-width:320px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                ${r.data}
                            </div>
                        </td>
                        <td>${new Date(r.generatedDate || Date.now()).toLocaleDateString()}</td>
                    </tr>
                `).join('');
            }
        }
    }

    openCreateReportModal() {
        setValue('reportType', 'Daily Financial Audit');
        setValue('reportDescription', 'Automated end-of-day revenue, completed rides, and settlement report.');
        this.openModal('reportModal');
    }

    async saveReport() {
        const reportType = getValue('reportType').trim();
        const description = getValue('reportDescription').trim();
        const generatedDate = new Date().toISOString();
        const data = `Generated automatically at ${new Date().toLocaleTimeString()} by Admin.`;

        try {
            await window.api.createReport({ reportType, description, generatedDate, data });
            this.showToast('Report generated successfully', 'success');
            this.closeModal('reportModal');
            await this.renderReports();
        } catch (err) {
            this.showToast(`Report creation failed: ${err.message}`, 'error');
        }
    }

    exportDataToCSV() {
        let csv = "ID,Name,Email,Phone,Active\n";
        this.cachedData.customers.forEach(c => {
            csv += `"${c.id}","${c.name}","${c.email}","${c.phone}","${c.isActive}"\n`;
        });
        const blob = new Blob([csv], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `RideManagement_Customers_${Date.now()}.csv`;
        a.click();
        this.showToast('Exported customer records to CSV', 'success');
    }

    // ============================================================
    // 10. RATINGS, FEEDBACK & AUDIT LOGS
    // ============================================================
    async renderAuditLogs() {
        const [ratings, auditLogs] = await Promise.all([
            window.api.getRatings().catch(() => []),
            window.api.getAuditLogs().catch(() => [])
        ]);

        this.cachedData.ratings = ratings || [];
        this.cachedData.auditLogs = auditLogs || [];

        // Ratings Cards
        const ratingsContainer = document.getElementById('ratingsGrid');
        if (ratingsContainer) {
            if (this.cachedData.ratings.length === 0) {
                ratingsContainer.innerHTML = `<div style="grid-column:1/-1;text-align:center;padding:2rem;color:var(--text-muted);">No reviews submitted yet.</div>`;
            } else {
                ratingsContainer.innerHTML = this.cachedData.ratings.map(r => `
                    <div class="card-panel" style="padding:1rem;">
                        <div style="display:flex;justify-content:space-between;align-items:center;">
                            <span style="color:var(--status-warning);font-size:1.1rem;font-weight:700;">
                                ${'★'.repeat(r.ratingValue)}${'☆'.repeat(5 - r.ratingValue)}
                            </span>
                            <span style="font-size:0.75rem;color:var(--text-muted);">${new Date(r.createdDate || Date.now()).toLocaleDateString()}</span>
                        </div>
                        <p style="font-size:0.875rem;margin:0.75rem 0;color:var(--text-primary);font-style:italic;">
                            "${r.feedback || 'No written comment provided.'}"
                        </p>
                        <div style="display:flex;justify-content:space-between;font-size:0.75rem;color:var(--text-muted);">
                            <span>Ride: #RIDE-${r.rideId}</span>
                            <span>Rider: #RIDER-${r.riderId}</span>
                        </div>
                    </div>
                `).join('');
            }
        }

        // Audit Logs Table
        const tbody = document.getElementById('auditTableBody');
        if (tbody) {
            if (this.cachedData.auditLogs.length === 0) {
                tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;padding:2rem;color:var(--text-muted);">No audit trails recorded.</td></tr>`;
            } else {
                tbody.innerHTML = this.cachedData.auditLogs.map(a => `
                    <tr>
                        <td>#LOG-${a.id}</td>
                        <td>
                            <strong style="color:var(--text-primary);">${a.action}</strong>
                        </td>
                        <td>
                            <span class="badge badge-neutral">${a.entityName} #${a.entityId}</span>
                        </td>
                        <td>
                            <span style="color:var(--brand-accent);font-weight:600;">${a.performedBy}</span>
                        </td>
                        <td>${a.description}</td>
                        <td style="font-size:0.8rem;color:var(--text-muted);">
                            ${new Date(a.performedAt || Date.now()).toLocaleString()}
                        </td>
                    </tr>
                `).join('');
            }
        }
    }

    openCreateRatingModal() {
        setValue('ratingRideId', '');
        setValue('ratingRiderId', '');
        setValue('ratingValue', '5');
        setValue('ratingFeedback', '');
        this.openModal('ratingModal');
    }

    async saveRating() {
        const rideId = Number(getValue('ratingRideId', '0'));
        const riderId = Number(getValue('ratingRiderId', '0'));
        const ratingValue = Number(getValue('ratingValue', '5'));
        const feedback = getValue('ratingFeedback').trim();

        if (!rideId || !riderId) {
            this.showToast('Please specify Ride ID and Rider ID', 'warning');
            return;
        }

        try {
            await window.api.createRating({ rideId, riderId, ratingValue, feedback, createdDate: new Date().toISOString() });
            this.showToast('Rating submitted', 'success');
            this.closeModal('ratingModal');
            await this.renderAuditLogs();
        } catch (err) {
            this.showToast(`Rating submission failed: ${err.message}`, 'error');
        }
    }

    // ============================================================
    // MODAL & TOAST HELPERS
    // ============================================================
    openModal(modalId) {
        document.getElementById(modalId)?.classList.add('active');
    }

    closeModal(modalId) {
        document.getElementById(modalId)?.classList.remove('active');
    }

    showToast(message, type = 'info') {
        const container = document.getElementById('toastContainer');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        let icon = 'info-circle';
        if (type === 'success') icon = 'check-circle';
        if (type === 'error') icon = 'exclamation-circle';
        if (type === 'warning') icon = 'exclamation-triangle';

        toast.innerHTML = `<i class="fas fa-${icon}"></i> <span>${message}</span>`;
        container.appendChild(toast);

        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 250);
        }, 4000);
    }
}

// Global App instance
window.app = new AdminApp();
window.addEventListener('DOMContentLoaded', () => window.app.init());
