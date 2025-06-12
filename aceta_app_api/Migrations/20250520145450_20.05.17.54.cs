using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _20051754 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OncesiFotoUrl",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "SonrasiFotoUrl",
                table: "TamirciRandevular");

            migrationBuilder.AddColumn<string>(
                name: "OncesiFotograflar",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "[]");

            migrationBuilder.AddColumn<string>(
                name: "SonrasiFotograflar",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "[]");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OncesiFotograflar",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "SonrasiFotograflar",
                table: "TamirciRandevular");

            migrationBuilder.AddColumn<string>(
                name: "OncesiFotoUrl",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SonrasiFotoUrl",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
