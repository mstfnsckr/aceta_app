using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Araclar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TC = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PlakaNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracTuru = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracMarkasi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracModeli = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracYili = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Araclar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AracTurler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AracTurler", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CekiciBireyseller",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Soyad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TC = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EPosta = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PlakaNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CekebilecegiAraclar = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TasimaSistemleri = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DestekEkipmanlari = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TeknikEkipmanlari = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KmBasiUcret = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Sifre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false),
                    Enlem = table.Column<double>(type: "float", nullable: true),
                    Boylam = table.Column<double>(type: "float", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CekiciBireyseller", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CekiciFirmalar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirmaAdi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VergiKimlikNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    YetkiliKisi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EPosta = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PlakaNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CekebilecegiAraclar = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TasimaSistemleri = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DestekEkipmanlari = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TeknikEkipmanlari = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KmBasiUcret = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Sifre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false),
                    Enlem = table.Column<double>(type: "float", nullable: true),
                    Boylam = table.Column<double>(type: "float", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CekiciFirmalar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DonanimDestekEkipmanlar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OzellikAdi = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DonanimDestekEkipmanlar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DonanimTasimaSistemler",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OzellikAdi = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DonanimTasimaSistemler", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "DonanimTeknikEkipmanlar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OzellikAdi = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DonanimTeknikEkipmanlar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Kullanicilar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Soyad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EPosta = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Sifre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DogumTarihi = table.Column<DateTime>(type: "datetime2", nullable: false),
                    TC = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KayitTarihi = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Kullanicilar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TamirciBireyseller",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Soyad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TC = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DukkanAdi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EPosta = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracTuru = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracMarkasi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracModeli = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Konum = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Sifre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TamirciBireyseller", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TamirciFirmalar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirmaAdi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    VergiKimlikNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    YetkiliKisi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DukkanAdi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EPosta = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracTuru = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracMarkasi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AracModeli = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Konum = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Sifre = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TamirciFirmalar", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AracMarkalar",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Arac_TurId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AracMarkalar", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AracMarkalar_AracTurler_Arac_TurId",
                        column: x => x.Arac_TurId,
                        principalTable: "AracTurler",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AracModeller",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ad = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Arac_MarkaId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AracModeller", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AracModeller_AracMarkalar_Arac_MarkaId",
                        column: x => x.Arac_MarkaId,
                        principalTable: "AracMarkalar",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AracMarkalar_Arac_TurId",
                table: "AracMarkalar",
                column: "Arac_TurId");

            migrationBuilder.CreateIndex(
                name: "IX_AracModeller_Arac_MarkaId",
                table: "AracModeller",
                column: "Arac_MarkaId");

            migrationBuilder.CreateIndex(
                name: "IX_Kullanicilar_EPosta",
                table: "Kullanicilar",
                column: "EPosta",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Araclar");

            migrationBuilder.DropTable(
                name: "AracModeller");

            migrationBuilder.DropTable(
                name: "CekiciBireyseller");

            migrationBuilder.DropTable(
                name: "CekiciFirmalar");

            migrationBuilder.DropTable(
                name: "DonanimDestekEkipmanlar");

            migrationBuilder.DropTable(
                name: "DonanimTasimaSistemler");

            migrationBuilder.DropTable(
                name: "DonanimTeknikEkipmanlar");

            migrationBuilder.DropTable(
                name: "Kullanicilar");

            migrationBuilder.DropTable(
                name: "TamirciBireyseller");

            migrationBuilder.DropTable(
                name: "TamirciFirmalar");

            migrationBuilder.DropTable(
                name: "AracMarkalar");

            migrationBuilder.DropTable(
                name: "AracTurler");
        }
    }
}
