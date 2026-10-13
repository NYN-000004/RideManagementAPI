using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RideManagementAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddPricingConfiguration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PricingConfigurations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BaseFare = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    PerKilometreFare = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    TimeFare = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    MinimumFare = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    PlatformFee = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PricingConfigurations", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PricingConfigurations");
        }
    }
}
