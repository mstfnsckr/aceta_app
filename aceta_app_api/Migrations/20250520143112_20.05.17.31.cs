using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _20051731 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OncesiFotoUrl",
                table: "CekiciRandevular");

            migrationBuilder.DropColumn(
                name: "SonrasiFotoUrl",
                table: "CekiciRandevular");
        }
    }
}
