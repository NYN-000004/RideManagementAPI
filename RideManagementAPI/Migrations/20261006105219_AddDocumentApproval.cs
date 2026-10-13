using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RideManagementAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddDocumentApproval : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DocumentApprovalStatus",
                table: "Riders",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DocumentApprovalStatus",
                table: "Riders");
        }
    }
}
