using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _06051736 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AracId",
                table: "CekiciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_CekiciRandevular_AracId",
                table: "CekiciRandevular",
                column: "AracId");

            migrationBuilder.AddForeignKey(
                name: "FK_CekiciRandevular_Araclar_AracId",
                table: "CekiciRandevular",
                column: "AracId",
                principalTable: "Araclar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CekiciRandevular_Araclar_AracId",
                table: "CekiciRandevular");

            migrationBuilder.DropIndex(
                name: "IX_CekiciRandevular_AracId",
                table: "CekiciRandevular");

            migrationBuilder.DropColumn(
                name: "AracId",
                table: "CekiciRandevular");
        }
    }
}
