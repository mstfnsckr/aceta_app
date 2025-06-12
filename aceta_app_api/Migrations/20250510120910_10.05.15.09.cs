using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _10051509 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamirciciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.AlterColumn<int>(
                name: "TamirciBireyselId",
                table: "TamirciRandevular",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular",
                column: "TamirciBireyselId",
                principalTable: "TamirciBireyseller",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.AlterColumn<int>(
                name: "TamirciBireyselId",
                table: "TamirciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TamirciciBireyselId",
                table: "TamirciRandevular",
                type: "int",
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular",
                column: "TamirciBireyselId",
                principalTable: "TamirciBireyseller",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
