using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace nikhy_ridecycle.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Rides",
                columns: table => new
                {
                    RideId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    BookingId = table.Column<long>(type: "bigint", nullable: true),
                    PassengerId = table.Column<long>(type: "bigint", nullable: false),
                    DriverId = table.Column<long>(type: "bigint", nullable: true),
                    PickupLocation = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    DestinationLocation = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    PickupLatitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    PickupLongitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    DestinationLatitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    DestinationLongitude = table.Column<decimal>(type: "numeric(10,7)", precision: 10, scale: 7, nullable: false),
                    Status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    Fare = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    Distance = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    EstimatedDuration = table.Column<int>(type: "integer", nullable: true),
                    RequestedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    AcceptedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    StartedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CompletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CancelledAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CancellationReason = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CancelledBy = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Rides", x => x.RideId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Rides_CreatedAt",
                table: "Rides",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Rides_DriverId",
                table: "Rides",
                column: "DriverId");

            migrationBuilder.CreateIndex(
                name: "IX_Rides_PassengerId",
                table: "Rides",
                column: "PassengerId");

            migrationBuilder.CreateIndex(
                name: "IX_Rides_Status",
                table: "Rides",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Rides_Status_CreatedAt",
                table: "Rides",
                columns: new[] { "Status", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Rides");
        }
    }
}
