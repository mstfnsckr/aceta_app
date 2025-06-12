using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _06051314 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AracMarkalar_AracTurler_Arac_TurId",
                table: "AracMarkalar");

            migrationBuilder.DropForeignKey(
                name: "FK_AracModeller_AracMarkalar_Arac_MarkaId",
                table: "AracModeller");

            migrationBuilder.RenameColumn(
                name: "Arac_MarkaId",
                table: "AracModeller",
                newName: "AracMarkaId");

            migrationBuilder.RenameIndex(
                name: "IX_AracModeller_Arac_MarkaId",
                table: "AracModeller",
                newName: "IX_AracModeller_AracMarkaId");

            migrationBuilder.RenameColumn(
                name: "Arac_TurId",
                table: "AracMarkalar",
                newName: "AracTurId");

            migrationBuilder.RenameIndex(
                name: "IX_AracMarkalar_Arac_TurId",
                table: "AracMarkalar",
                newName: "IX_AracMarkalar_AracTurId");

            migrationBuilder.CreateTable(
                name: "CekiciRandevular",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CekiciBireyselId = table.Column<int>(type: "int", nullable: false),
                    CekiciFirmaId = table.Column<int>(type: "int", nullable: false),
                    KullaniciId = table.Column<int>(type: "int", nullable: false),
                    KullaniciBaslangıcKonumu = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CekiciBaslangıcKonumu = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Durum = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Ucret = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    RandevuTarihi = table.Column<DateTime>(type: "datetime2", nullable: false),
                    OnayTarihi = table.Column<DateTime>(type: "datetime2", nullable: true),
                    BaslamaTarihi = table.Column<DateTime>(type: "datetime2", nullable: true),
                    TamamlanmaTarihi = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CekiciRandevular", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CekiciRandevular_CekiciBireyseller_CekiciBireyselId",
                        column: x => x.CekiciBireyselId,
                        principalTable: "CekiciBireyseller",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CekiciRandevular_CekiciFirmalar_CekiciFirmaId",
                        column: x => x.CekiciFirmaId,
                        principalTable: "CekiciFirmalar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CekiciRandevular_Kullanicilar_KullaniciId",
                        column: x => x.KullaniciId,
                        principalTable: "Kullanicilar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TamirciRandevular",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TamirciRandevular", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CekiciRandevular_CekiciBireyselId",
                table: "CekiciRandevular",
                column: "CekiciBireyselId");

            migrationBuilder.CreateIndex(
                name: "IX_CekiciRandevular_CekiciFirmaId",
                table: "CekiciRandevular",
                column: "CekiciFirmaId");

            migrationBuilder.CreateIndex(
                name: "IX_CekiciRandevular_KullaniciId",
                table: "CekiciRandevular",
                column: "KullaniciId");

            migrationBuilder.AddForeignKey(
                name: "FK_AracMarkalar_AracTurler_AracTurId",
                table: "AracMarkalar",
                column: "AracTurId",
                principalTable: "AracTurler",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AracModeller_AracMarkalar_AracMarkaId",
                table: "AracModeller",
                column: "AracMarkaId",
                principalTable: "AracMarkalar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AracMarkalar_AracTurler_AracTurId",
                table: "AracMarkalar");

            migrationBuilder.DropForeignKey(
                name: "FK_AracModeller_AracMarkalar_AracMarkaId",
                table: "AracModeller");

            migrationBuilder.DropTable(
                name: "CekiciRandevular");

            migrationBuilder.DropTable(
                name: "TamirciRandevular");

            migrationBuilder.RenameColumn(
                name: "AracMarkaId",
                table: "AracModeller",
                newName: "Arac_MarkaId");

            migrationBuilder.RenameIndex(
                name: "IX_AracModeller_AracMarkaId",
                table: "AracModeller",
                newName: "IX_AracModeller_Arac_MarkaId");

            migrationBuilder.RenameColumn(
                name: "AracTurId",
                table: "AracMarkalar",
                newName: "Arac_TurId");

            migrationBuilder.RenameIndex(
                name: "IX_AracMarkalar_AracTurId",
                table: "AracMarkalar",
                newName: "IX_AracMarkalar_Arac_TurId");

            migrationBuilder.AddForeignKey(
                name: "FK_AracMarkalar_AracTurler_Arac_TurId",
                table: "AracMarkalar",
                column: "Arac_TurId",
                principalTable: "AracTurler",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AracModeller_AracMarkalar_Arac_MarkaId",
                table: "AracModeller",
                column: "Arac_MarkaId",
                principalTable: "AracMarkalar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
