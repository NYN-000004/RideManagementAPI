using Microsoft.EntityFrameworkCore;
using Nikhy_demo.Models;

namespace Nikhy_demo.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(
            DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Ride> Rides { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Ride>(entity =>
            {
                entity.ToTable("Rides");

                entity.HasKey(r => r.RideId);

                entity.Property(r => r.Status)
                    .HasConversion<string>()
                    .HasMaxLength(30)
                    .IsRequired();

                entity.Property(r => r.PickupLocation)
                    .HasMaxLength(200)
                    .IsRequired();

                entity.Property(r => r.DestinationLocation)
                    .HasMaxLength(200)
                    .IsRequired();

                entity.Property(r => r.Fare)
                    .HasPrecision(10, 2);

                entity.Property(r => r.Distance)
                    .HasPrecision(10, 2);

                entity.Property(r => r.PickupLatitude)
                    .HasPrecision(10, 7);

                entity.Property(r => r.PickupLongitude)
                    .HasPrecision(10, 7);

                entity.Property(r => r.DestinationLatitude)
                    .HasPrecision(10, 7);

                entity.Property(r => r.DestinationLongitude)
                    .HasPrecision(10, 7);

                entity.HasIndex(r => r.PassengerId);

                entity.HasIndex(r => r.DriverId);

                entity.HasIndex(r => r.Status);

                entity.HasIndex(r => r.CreatedAt);

                entity.HasIndex(r => new
                {
                    r.Status,
                    r.CreatedAt
                });
            });
        }
    }
}