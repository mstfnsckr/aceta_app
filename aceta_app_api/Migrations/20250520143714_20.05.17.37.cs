using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _20051737 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OncesiFotoUrl",
                table: "CekiciRandevular");

            migrationBuilder.DropColumn(
                name: "SonrasiFotoUrl",
                table: "CekiciRandevular");

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OncesiFotoUrl",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "SonrasiFotoUrl",
                table: "TamirciRandevular");

            migrationBuilder.AddColumn<string>(
                name: "OncesiFotoUrl",
                table: "CekiciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "SonrasiFotoUrl",
                table: "CekiciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }
    }
}
