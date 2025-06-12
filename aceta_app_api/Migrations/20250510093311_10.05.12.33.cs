using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _10051233 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AracId",
                table: "TamirciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "BaslamaTarihi",
                table: "TamirciRandevular",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Durum",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "KullaniciBaslangıcKonumu",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "KullaniciId",
                table: "TamirciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "OnayTarihi",
                table: "TamirciRandevular",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RandevuTarihi",
                table: "TamirciRandevular",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "TamamlanmaTarihi",
                table: "TamirciRandevular",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TamirciBaslangıcKonumu",
                table: "TamirciRandevular",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "TamirciBireyselId",
                table: "TamirciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TamirciFirmaId",
                table: "TamirciRandevular",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TamirciciBireyselId",
                table: "TamirciRandevular",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Ucret",
                table: "TamirciRandevular",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_TamirciRandevular_AracId",
                table: "TamirciRandevular",
                column: "AracId");

            migrationBuilder.CreateIndex(
                name: "IX_TamirciRandevular_KullaniciId",
                table: "TamirciRandevular",
                column: "KullaniciId");

            migrationBuilder.CreateIndex(
                name: "IX_TamirciRandevular_TamirciBireyselId",
                table: "TamirciRandevular",
                column: "TamirciBireyselId");

            migrationBuilder.CreateIndex(
                name: "IX_TamirciRandevular_TamirciFirmaId",
                table: "TamirciRandevular",
                column: "TamirciFirmaId");

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_Araclar_AracId",
                table: "TamirciRandevular",
                column: "AracId",
                principalTable: "Araclar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_Kullanicilar_KullaniciId",
                table: "TamirciRandevular",
                column: "KullaniciId",
                principalTable: "Kullanicilar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular",
                column: "TamirciBireyselId",
                principalTable: "TamirciBireyseller",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TamirciRandevular_TamirciFirmalar_TamirciFirmaId",
                table: "TamirciRandevular",
                column: "TamirciFirmaId",
                principalTable: "TamirciFirmalar",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_Araclar_AracId",
                table: "TamirciRandevular");

            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_Kullanicilar_KullaniciId",
                table: "TamirciRandevular");

            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_TamirciBireyseller_TamirciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.DropForeignKey(
                name: "FK_TamirciRandevular_TamirciFirmalar_TamirciFirmaId",
                table: "TamirciRandevular");

            migrationBuilder.DropIndex(
                name: "IX_TamirciRandevular_AracId",
                table: "TamirciRandevular");

            migrationBuilder.DropIndex(
                name: "IX_TamirciRandevular_KullaniciId",
                table: "TamirciRandevular");

            migrationBuilder.DropIndex(
                name: "IX_TamirciRandevular_TamirciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.DropIndex(
                name: "IX_TamirciRandevular_TamirciFirmaId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "AracId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "BaslamaTarihi",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "Durum",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "KullaniciBaslangıcKonumu",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "KullaniciId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "OnayTarihi",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "RandevuTarihi",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamamlanmaTarihi",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamirciBaslangıcKonumu",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamirciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamirciFirmaId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "TamirciciBireyselId",
                table: "TamirciRandevular");

            migrationBuilder.DropColumn(
                name: "Ucret",
                table: "TamirciRandevular");
        }
    }
}
