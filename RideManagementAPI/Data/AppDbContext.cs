using Microsoft.EntityFrameworkCore;
using RideManagementAPI.Models;

namespace RideManagementAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Ride> Rides { get; set; }
        public DbSet<Admin> Admins { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<Rider> Riders { get; set; }
        public DbSet<PricingConfiguration> PricingConfigurations { get; set; }
        public DbSet<PlatformSetting> PlatformSettings { get; set; }
        public DbSet<SurgeConfiguration> SurgeConfigurations { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<Report> Reports { get; set; }        public DbSet<OperationalData> OperationalData { get; set; }
        public DbSet<Rating> Ratings { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }
    }
}