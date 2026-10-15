/**
 * Mock Data Repository for Nikhy Ride Management Admin Dashboard
 * Used exclusively when the live backend is offline or when previewing Demo Mode.
 */
const MockData = {
    overviewStats: {
        totalRides: 1428,
        activeRides: 42,
        onlineRiders: 118,
        pendingApprovals: 7,
        totalCustomers: 3890,
        revenueToday: 84520.00,
        avgRating: 4.82,
        completedToday: 320
    },

    customers: [
        { id: 101, name: "Aarav Sharma", email: "aarav.sharma@example.com", phone: "+91 98765 43210", isActive: true },
        { id: 102, name: "Priya Patel", email: "priya.patel@example.com", phone: "+91 98765 43211", isActive: true },
        { id: 103, name: "Rohan Mehta", email: "rohan.mehta@example.com", phone: "+91 98765 43212", isActive: false },
        { id: 104, name: "Sneha Reddy", email: "sneha.reddy@example.com", phone: "+91 98765 43213", isActive: true },
        { id: 105, name: "Vikram Verma", email: "vikram.verma@example.com", phone: "+91 98765 43214", isActive: true },
        { id: 106, name: "Ananya Iyer", email: "ananya.iyer@example.com", phone: "+91 98765 43215", isActive: true },
        { id: 107, name: "Karan Malhotra", email: "karan.m@example.com", phone: "+91 98765 43216", isActive: false }
    ],

    riders: [
        { id: 1, name: "Rajesh Kumar", email: "rajesh.k@example.com", phone: "+91 98111 22334", vehicleNumber: "AP-37-AB-1234", licenseNumber: "DL-IND-2023-8901", approvalStatus: "Approved", documentApprovalStatus: "Approved", isActive: true },
        { id: 2, name: "Approval Test Rider", email: "approvalrider@gmail.com", phone: "9876543210", vehicleNumber: "AP37AB5678", licenseNumber: "DL9876543210", approvalStatus: "Approved", documentApprovalStatus: "Pending", isActive: true },
        { id: 3, name: "Rejection Test Rider", email: "rejectrider@gmail.com", phone: "9876543210", vehicleNumber: "AP37REJECT", licenseNumber: "DL9876543210", approvalStatus: "Approved", documentApprovalStatus: "Rejected", isActive: true },
        { id: 4, name: "Suresh Babu", email: "suresh.babu@example.com", phone: "+91 98222 33445", vehicleNumber: "AP-37-CD-5678", licenseNumber: "DL-IND-2022-4412", approvalStatus: "Pending", documentApprovalStatus: "Pending", isActive: false },
        { id: 5, name: "Kiran Rao", email: "kiran.rao@example.com", phone: "+91 98333 44556", vehicleNumber: "TS-09-EF-9012", licenseNumber: "DL-IND-2024-1188", approvalStatus: "Pending", documentApprovalStatus: "Pending", isActive: false },
        { id: 6, name: "Mahesh Naidu", email: "mahesh.n@example.com", phone: "+91 98444 55667", vehicleNumber: "AP-16-GH-3456", licenseNumber: "DL-IND-2021-9922", approvalStatus: "Rejected", documentApprovalStatus: "Rejected", isActive: false }
    ],

    rides: [
        { id: 201, pickupLocation: "Bhimavaram Railway Station", dropLocation: "SRKR Engineering College", rideTime: new Date(Date.now() - 15 * 60000).toISOString(), availableSeats: 3, price: 180, status: 1 }, // 1 = In Progress
        { id: 202, pickupLocation: "RTC Bus Stand", dropLocation: "DNR College Ground", rideTime: new Date(Date.now() - 35 * 60000).toISOString(), availableSeats: 2, price: 120, status: 2 }, // 2 = Completed
        { id: 203, pickupLocation: "Somaram Temple", dropLocation: "Town Railway Station", rideTime: new Date(Date.now() + 45 * 60000).toISOString(), availableSeats: 4, price: 250, status: 0 }, // 0 = Scheduled
        { id: 204, pickupLocation: "Undi Road Junction", dropLocation: "Mavullamma Temple", rideTime: new Date(Date.now() - 5 * 60000).toISOString(), availableSeats: 1, price: 95, status: 1 },
        { id: 205, pickupLocation: "Palakollu Highway", dropLocation: "Bhimavaram Center", rideTime: new Date(Date.now() - 120 * 60000).toISOString(), availableSeats: 3, price: 340, status: 2 },
        { id: 206, pickupLocation: "Housing Board Colony", dropLocation: "Civil Hospital", rideTime: new Date(Date.now() - 80 * 60000).toISOString(), availableSeats: 2, price: 110, status: 3 } // 3 = Cancelled
    ],

    pricing: [
        { id: 1, baseFare: 50.00, perKilometreFare: 14.50, timeFare: 1.50, minimumFare: 70.00, platformFee: 15.00, isActive: true },
        { id: 2, baseFare: 40.00, perKilometreFare: 12.00, timeFare: 1.00, minimumFare: 50.00, platformFee: 10.00, isActive: false }
    ],

    surge: [
        { id: 1, area: "Bhimavaram", surgeMultiplier: 1.50, isActive: true },
        { id: 2, area: "Railway Station & Bus Stand Hub", surgeMultiplier: 1.80, isActive: true },
        { id: 3, area: "SRKR Campus Zone", surgeMultiplier: 1.25, isActive: true },
        { id: 4, area: "Palakollu Bypass", surgeMultiplier: 1.00, isActive: false }
    ],

    settings: [
        { id: 1, key: "PlatformCommissionPercent", value: "15%", isActive: true },
        { id: 2, key: "AutoDispatchRadiusKm", value: "5.5", isActive: true },
        { id: 3, key: "MaxSearchTimeoutSeconds", value: "90", isActive: true },
        { id: 4, key: "AllowCashPayment", value: "true", isActive: true },
        { id: 5, key: "EmergencySosNumber", value: "112", isActive: true },
        { id: 6, key: "MaintenanceMode", value: "false", isActive: true }
    ],

    payments: [
        { id: 501, rideId: 202, amount: 120.00, paymentMethod: "UPI / GooglePay", paymentStatus: "Completed", transactionId: "TXN_UPI_982341", paymentDate: new Date(Date.now() - 30 * 60000).toISOString() },
        { id: 502, rideId: 205, amount: 340.00, paymentMethod: "Credit Card (Visa)", paymentStatus: "Completed", transactionId: "TXN_CC_887214", paymentDate: new Date(Date.now() - 110 * 60000).toISOString() },
        { id: 503, rideId: 201, amount: 180.00, paymentMethod: "Wallet Balance", paymentStatus: "Pending", transactionId: "TXN_WLT_771920", paymentDate: new Date(Date.now() - 10 * 60000).toISOString() },
        { id: 504, rideId: 206, amount: 110.00, paymentMethod: "Cash", paymentStatus: "Failed", transactionId: "TXN_CSH_FAILED", paymentDate: new Date(Date.now() - 75 * 60000).toISOString() }
    ],

    reports: [
        { id: 1, reportType: "Daily Revenue Summary", description: "Aggregated gross and net platform commissions for current day.", generatedDate: new Date().toISOString(), data: "Total Rides: 320 | Gross GMV: ₹84,520 | Commission Earned: ₹12,678" },
        { id: 2, reportType: "Rider Utilization Index", description: "Hourly driver fleet availability and active engagement ratio.", generatedDate: new Date(Date.now() - 86400000).toISOString(), data: "Avg Online: 118 | Peak Demand: 18:00 - 21:00 | Driver Fulfillment: 94.2%" },
        { id: 3, reportType: "Customer Acquisition & Retention", description: "New rider signups, activation rate, and 30-day retention curve.", generatedDate: new Date(Date.now() - 172800000).toISOString(), data: "New Signups: 145 | Returning Riders: 82% | Churn: 2.1%" }
    ],

    operationalData: [
        { id: 1, metricName: "Average Driver ETA", value: "4.2 mins", description: "Average duration for rider arrival post booking acceptance", recordedDate: new Date().toISOString() },
        { id: 2, metricName: "Fleet Utilization Rate", value: "82.4%", description: "Percentage of online drivers actively on trips", recordedDate: new Date().toISOString() },
        { id: 3, metricName: "Ride Completion Rate", value: "96.8%", description: "Total successful rides vs cancellations across all sectors", recordedDate: new Date().toISOString() },
        { id: 4, metricName: "Server Response Latency", value: "24 ms", description: "Average latency recorded by ASP.NET Core API gateway", recordedDate: new Date().toISOString() },
        { id: 5, metricName: "Dispute Rate", value: "0.14%", description: "Fare disputes and rider complaints filed per 1000 rides", recordedDate: new Date().toISOString() }
    ],

    ratings: [
        { id: 1, rideId: 202, riderId: 1, ratingValue: 5, feedback: "Very polite driver, neat car and reached on time!", createdDate: new Date(Date.now() - 25 * 60000).toISOString() },
        { id: 2, rideId: 205, riderId: 1, ratingValue: 5, feedback: "Smooth ride, drove carefully on the bypass.", createdDate: new Date(Date.now() - 95 * 60000).toISOString() },
        { id: 3, rideId: 204, riderId: 2, ratingValue: 4, feedback: "Good experience, but AC was slightly low.", createdDate: new Date(Date.now() - 150 * 60000).toISOString() },
        { id: 4, rideId: 206, riderId: 3, ratingValue: 2, feedback: "Driver was late and cancelled without proper communication.", createdDate: new Date(Date.now() - 240 * 60000).toISOString() }
    ],

    auditLogs: [
        { id: 1, action: "APPROVE_RIDER", entityName: "Rider", entityId: 2, performedBy: "admin", performedAt: new Date(Date.now() - 60 * 60000).toISOString(), description: "Admin approved rider registration for AP37AB5678" },
        { id: 2, action: "SURGE_UPDATE", entityName: "SurgeConfiguration", entityId: 1, performedBy: "admin", performedAt: new Date(Date.now() - 120 * 60000).toISOString(), description: "Updated surge multiplier for Bhimavaram zone to 1.5x" },
        { id: 3, action: "SETTINGS_MODIFY", entityName: "PlatformSetting", entityId: 1, performedBy: "admin", performedAt: new Date(Date.now() - 240 * 60000).toISOString(), description: "Updated BaseFare configuration to ₹50.00" },
        { id: 4, action: "DOCUMENT_REJECT", entityName: "Rider", entityId: 3, performedBy: "admin", performedAt: new Date(Date.now() - 360 * 60000).toISOString(), description: "Rejected invalid license document for Rejection Test Rider" },
        { id: 5, action: "ADMIN_LOGIN", entityName: "Admin", entityId: 1, performedBy: "admin", performedAt: new Date(Date.now() - 480 * 60000).toISOString(), description: "Successful JWT admin authentication from 127.0.0.1" }
    ]
};
