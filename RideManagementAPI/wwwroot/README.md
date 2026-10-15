# 🚖 NIKHY Ride Management — Admin Dashboard

A comprehensive, enterprise-grade administrative dashboard designed for the **Nikhy Ride Management Solution**. Connects directly to the existing **ASP.NET Core Web API** (`RideManagementAPI`) on `http://localhost:5012` with JWT authentication, live operational monitoring, and full CRUD management.

---

## 🌟 Key Features & Dashboard Modules

The admin dashboard integrates all 10 core operational modules:

| Section | Route / Controller | Description |
| :--- | :--- | :--- |
| **1. Overview** | `/api/Ride/monitoring`, `/api/Rider`, `/api/Customer`, `/api/Payment` | Live executive KPIs (Active Rides, Online Drivers, Revenue Today, Pending Approvals), revenue & volume velocity charts (Chart.js), and quick audit activity feed. |
| **2. Customer Management** | `/api/Customer` | Customer directory, real-time search, active/inactive filters, Add Customer modal, Edit Customer, and CSV export. |
| **3. Rider Management & Approvals** | `/api/Rider` | Rider directory with vehicle plate & license numbers. Features one-click **Approve** (`PUT /api/Rider/approve/{id}`) and **Reject** (`PUT /api/Rider/reject/{id}`) workflows. |
| **4. Document Approval** | `/api/Rider/document-approve/{id}`, `/document-reject/{id}` | Dedicated compliance workqueue for driver license and vehicle RC verification before clearing riders for dispatch. |
| **5. Ride Monitoring** | `/api/Ride/monitoring`, `/api/Ride` | Real-time trip feed with pickup, drop-off, available seats, fare, and status filters (`Scheduled`, `In Progress`, `Completed`, `Cancelled`). |
| **6. Pricing & Surge** | `/api/Pricing`, `/api/Surge` | Dual-pane control: Configure base pricing algorithm rules (`BaseFare`, `PerKmRate`, `TimeFare`, `MinimumFare`, `PlatformFee`) and geographic surge multiplier zones. |
| **7. Platform Settings** | `/api/PlatformSettings` | Key-value system parameter manager with inline edit, add, and deactivate controls. |
| **8. Payment Monitoring** | `/api/Payment` | Financial transaction ledger with payment method breakdown (UPI, Card, Wallet, Cash), settlement status, and transaction search. |
| **9. Reports & Metrics** | `/api/Report`, `/api/OperationalData` | Real-time operational telemetry (driver arrival ETA, fleet utilization %, server latency) alongside generated analytical reports. |
| **10. Ratings & Audit Logs** | `/api/Rating`, `/api/AuditLog` | Customer review cards with star ratings (1-5★) and chronological security audit trail tracker recording administrative operator actions. |

---

## 🚀 How to Run the Dashboard

### Option A: Direct Backend Hosting (Recommended)
Because the dashboard files are mirrored to `RideManagementAPI/wwwroot/`, running the backend serves the dashboard directly:

1. In PowerShell / Terminal, navigate to the API directory:
   ```powershell
   cd C:\Users\chint\source\repos\RideManagementSolution\RideManagementAPI
   dotnet run --launch-profile "http"
   ```
2. Open your browser and navigate to:
   ```text
   http://localhost:5012/
   ```
   *The dashboard will load immediately with zero CORS hurdles and auto-connect to the backend API!*

---

### Option B: Standalone Web Client
You can also run or open the dashboard directly from `frontend/admin_dashboard/`:

1. Serve with any local HTTP server (or open `index.html` in your browser):
   ```powershell
   npx serve C:\Users\chint\source\repos\RideManagementSolution\frontend\admin_dashboard -p 3000
   ```
2. The dashboard will automatically connect to `http://localhost:5012` using the enabled CORS policy.
3. If the backend URL changes, click the **Settings ⚙️** icon in the sidebar to configure the API base URL.

---

## 🔐 Authentication Details

* **Default Admin Username**: `admin`
* **Default Admin Password**: `1234`
* **Auth Endpoint**: `POST /api/Admin/login`
* **Token Storage**: Managed dynamically in `localStorage` (`ride_admin_jwt_token`), never hardcoded, and attached to all HTTP requests via `Authorization: Bearer <token>`.

---

## ⚡ Live vs. Demo Preview Mode

* **Live Mode (Default)**: Directly queries your local SQL Server database via ASP.NET Core endpoints.
* **Demo Mode**: Can be toggled at any time using the **Live/Demo Switch** button in the top navbar. When the backend or database is offline, Demo Mode enables full exploration of all 10 modules using rich, realistic transit operations data.
