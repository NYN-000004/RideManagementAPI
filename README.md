# 🚖 Nikhy RideCycle - Ride Lifecycle Management API

An enterprise-grade ASP.NET Core Web API implementing an end-to-end Ride Booking & State Management Lifecycle, built with **.NET 10**, **Entity Framework Core**, and **PostgreSQL (Npgsql)**.

---

## 📌 Table of Contents
1. [Architecture Overview](#-architecture-overview)
2. [PostgreSQL Setup & Connection Guide](#-postgresql-setup--connection-guide)
3. [The Ride Lifecycle State Machine](#-the-ride-lifecycle-state-machine)
4. [Database Seeding & Demo Data](#-database-seeding--demo-data)
5. [API Endpoints Reference](#-api-endpoints-reference)
6. [How to Run and Test](#-how-to-run-and-test)
7. [Code Deep Dive for Learning](#-code-deep-dive-for-learning)

---

## 🏗️ Architecture Overview

The solution follows clean architectural separation of concerns:

```
Nikhy_demo (nikhy_ridecycle)
├── Controllers/
│   └── RidesController.cs        --> Handles HTTP requests, query/body params, HTTP status codes
├── Services/
│   ├── IRideService.cs           --> Business contract / service interface
│   └── RideService.cs            --> Core business rules, state machine transitions, validations
├── Data/
│   ├── ApplicationDbContext.cs   --> EF Core PostgreSQL DbContext, Fluent API mapping, indexes
│   ├── DatabaseSeeder.cs         --> Auto-migrates and seeds 8 realistic demo rides
│   └── seed_rides.sql            --> Standalone SQL script for pgAdmin / psql
├── Models/
│   └── Ride.cs                   --> Ride database entity (maps to "Rides" table)
├── DTOs/                         --> Data Transfer Objects (decoupling API contract from DB)
│   ├── CreateRideRequest.cs
│   ├── CancelRideRequest.cs
│   ├── UpdateRideStatusRequest.cs
│   ├── RideResponse.cs
│   └── RideHistoryResponse.cs
├── Enums/
│   └── RideStatus.cs             --> Enum defining all 8 ride states
├── Migrations/                   --> EF Core code-first migration files
├── appsettings.json              --> PostgreSQL connection string & config
└── nikhy_ridecycle.http          --> Ready-to-run HTTP requests for testing all endpoints
```

---

## 🐘 PostgreSQL Setup & Connection Guide

### 1. Connection String Anatomy
In `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=nikhy_ridecycle_db;Username=postgres;Password=YOUR_POSTGRES_PASSWORD"
  }
}
```

| Parameter | Meaning | Default / Example |
| :--- | :--- | :--- |
| `Host` | Address of the PostgreSQL server | `localhost` (running locally on your machine) |
| `Port` | Port PostgreSQL is listening on | `5432` |
| `Database` | Target database name | `nikhy_ridecycle_db` |
| `Username` | PostgreSQL database user | `postgres` (default superuser) |
| `Password` | Password created during installation | Replace `YOUR_POSTGRES_PASSWORD` with your actual password |

### 2. How to Create the Database

#### Option A: Using pgAdmin 4 (GUI)
1. Open **pgAdmin 4** from your Windows Start Menu.
2. Enter your master password to unlock pgAdmin.
3. In the left panel, expand **Servers** -> **PostgreSQL 18**.
4. Right-click on **Databases** -> **Create** -> **Database...**.
5. Set Database name: `nikhy_ridecycle_db`.
6. Click **Save**.

#### Option B: Using psql (Command Line)
Open PowerShell or Command Prompt and run:
```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE nikhy_ridecycle_db;"
```

### 3. Forgot Your PostgreSQL Password?
If you don't recall the password you set during PostgreSQL installation:
1. Open file: `C:\Program Files\PostgreSQL\18\data\pg_hba.conf` in Notepad (as Administrator).
2. Find lines near the bottom:
   ```text
   # IPv4 local connections:
   host    all             all             127.0.0.1/32            scram-sha-256
   ```
3. Temporarily change `scram-sha-256` to `trust` and save the file.
4. Restart PostgreSQL service in PowerShell (Run as Administrator):
   ```powershell
   Restart-Service postgresql-x64-18
   ```
5. Connect without password and reset it:
   ```powershell
   & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"
   ```
6. Change `trust` back to `scram-sha-256` in `pg_hba.conf` and restart the service again.

---

## 🔄 The Ride Lifecycle State Machine

The application strictly validates state transitions to ensure realistic taxi ride operations:

```
[REQUESTED] (Ride created by passenger)
     │
     ▼
[SEARCHING] (Matching available drivers)
     │
     ├───► [CANCELLED] (Passenger can cancel)
     ▼
[ACCEPTED] (Driver accepts ride)
     │
     ├───► [CANCELLED] (Can still cancel)
     ▼
[RIDER_ARRIVING] (Driver is on the way to pickup)
     │
     ├───► [CANCELLED] (Can cancel before arrival)
     ▼
[ARRIVED] (Driver arrived at pickup point)
     │
     ▼
 [STARTED] (Passenger onboard, trip in progress)
     │
     ▼
[COMPLETED] (Passenger dropped off, trip ended - Terminal)
```

### Transition & Business Rules:
- **Terminal States**: `COMPLETED` and `CANCELLED` cannot transition to any other state.
- **Cancellation Rule**: Rides can only be cancelled while in `REQUESTED`, `SEARCHING`, `ACCEPTED`, or `RIDER_ARRIVING`. Once the driver marks `ARRIVED` or `STARTED`, cancellation is rejected (`409 Conflict`).
- **Driver Requirement**: A ride cannot transition to `STARTED` or `COMPLETED` without a valid `DriverId`.
- **Coordinate Validation**: Pickup & destination latitude must be between `[-90, 90]`, and longitude between `[-180, 180]`.

---

## 🌱 Database Seeding & Demo Data

The project contains 8 pre-seeded demo rides covering every lifecycle state so you can test all API endpoints immediately:

| RideId | BookingId | PassengerId | DriverId | From -> To | Status |
| :---: | :---: | :---: | :---: | :--- | :--- |
| **1** | 1001 | 101 | *None* | Connaught Place -> IGI Airport | `REQUESTED` |
| **2** | 1002 | 102 | *None* | DLF Phase 2 Cyber Hub -> Sector 29 Gurugram | `SEARCHING` |
| **3** | 1003 | 103 | 201 | Hauz Khas Village -> Select Citywalk | `ACCEPTED` |
| **4** | 1004 | 104 | 202 | BKC Mumbai -> CSMT Mumbai | `RIDER_ARRIVING` |
| **5** | 1005 | 105 | 203 | MG Road Bengaluru -> Indiranagar | `ARRIVED` |
| **6** | 1006 | 106 | 204 | Koramangala -> Whitefield ITPL | `STARTED` |
| **7** | 1007 | 107 | 205 | Hitec City -> Hyderabad Airport | `COMPLETED` |
| **8** | 1008 | 108 | *None* | Salt Lake -> Park Street Kolkata | `CANCELLED` |

### Two Ways Seeding is Available:
1. **Automatic on App Launch**: When `dotnet run` starts and the connection string is valid, `Program.cs` automatically applies EF Core migrations and seeds these 8 rides if the table is empty.
2. **Manual SQL Script**: You can also open and run [`nikhy_ridecycle/Data/seed_rides.sql`](nikhy_ridecycle/Data/seed_rides.sql) in pgAdmin Query Tool.

---

## 📡 API Endpoints Reference

Base URL: `https://localhost:7275` (or `http://localhost:5231`)

| HTTP Method | Route | Description |
| :--- | :--- | :--- |
| `POST` | `/api/rides` | Create a new ride booking (starts in `REQUESTED` then `SEARCHING`) |
| `GET` | `/api/rides/{rideId}` | Get complete ride details by ID |
| `POST` | `/api/rides/{rideId}/accept?driverId={id}` | Driver accepts the ride |
| `PATCH` | `/api/rides/{rideId}/status` | Generic status transition |
| `POST` | `/api/rides/{rideId}/arriving` | Driver marks status as arriving |
| `POST` | `/api/rides/{rideId}/arrived` | Driver arrived at pickup location |
| `POST` | `/api/rides/{rideId}/start` | Driver starts the trip |
| `POST` | `/api/rides/{rideId}/complete` | Driver completes the trip |
| `POST` | `/api/rides/{rideId}/cancel` | Cancel ride with reason & initiator |
| `GET` | `/api/rides/history` | Paginated ride history with passenger/driver/status filters |

---

## 🚀 How to Run and Test

### Step 1: Set your PostgreSQL Password
Open `nikhy_ridecycle/appsettings.json` and replace `postgres` with your actual PostgreSQL password:
```json
"DefaultConnection": "Host=localhost;Port=5432;Database=nikhy_ridecycle_db;Username=postgres;Password=your_password"
```

### Step 2: Run the Web API
In PowerShell or terminal:
```powershell
dotnet run --project nikhy_ridecycle/nikhy_ridecycle.csproj
```

### Step 3: Open Swagger UI
Navigate to:
```text
https://localhost:7275/swagger
```
You can interactively test every single endpoint directly from the browser!

### Step 4: Use the HTTP Client File
Open [`nikhy_ridecycle/nikhy_ridecycle.http`](nikhy_ridecycle/nikhy_ridecycle.http) in Visual Studio or VS Code (with REST Client extension) to run pre-configured test requests with 1-click.

---

## 🧠 Code Deep Dive for Learning

### 1. High Performance Indexes in EF Core
In `ApplicationDbContext.cs`:
```csharp
modelBuilder.Entity<Ride>(entity =>
{
    entity.ToTable("Rides");
    entity.HasKey(r => r.RideId);

    // Single column indexes for fast lookups by user or status
    entity.HasIndex(r => r.PassengerId);
    entity.HasIndex(r => r.DriverId);
    entity.HasIndex(r => r.Status);
    entity.HasIndex(r => r.CreatedAt);

    // Composite index for fast filtering active rides by date
    entity.HasIndex(r => new { r.Status, r.CreatedAt });
});
```
*Why this matters:* In ride-hailing apps, queries like "Show me all SEARCHING rides created in the last 10 minutes" happen thousands of times a second. The composite index `(Status, CreatedAt)` makes this query instantaneous.

### 2. State Transition Pattern
In `RideService.cs`:
```csharp
bool valid = current switch
{
    RideStatus.REQUESTED => next == RideStatus.SEARCHING || next == RideStatus.CANCELLED,
    RideStatus.SEARCHING => next == RideStatus.ACCEPTED  || next == RideStatus.CANCELLED,
    RideStatus.ACCEPTED  => next == RideStatus.RIDER_ARRIVING || next == RideStatus.CANCELLED,
    RideStatus.RIDER_ARRIVING => next == RideStatus.ARRIVED || next == RideStatus.CANCELLED,
    RideStatus.ARRIVED   => next == RideStatus.STARTED,
    RideStatus.STARTED   => next == RideStatus.COMPLETED,
    _ => false
};
```
*Why this matters:* Using C# pattern matching ensures no invalid transitions (e.g. going directly from `REQUESTED` to `COMPLETED`) can corrupt your database state.
