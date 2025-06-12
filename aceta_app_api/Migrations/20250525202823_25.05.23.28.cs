using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _25052328 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Puan",
                table: "TamirciRandevular",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Puan",
                table: "CekiciRandevular",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Puan",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "Puan",
                table: "CekiciRandevular");
        }
    }
}
