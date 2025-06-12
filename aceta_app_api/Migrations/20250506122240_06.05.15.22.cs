using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace aceta_app_api.Migrations
{
    /// <inheritdoc />
    public partial class _06051522 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CekiciRandevular_CekiciBireyseller_CekiciBireyselId",
                table: "CekiciRandevular");

            migrationBuilder.DropForeignKey(
                name: "FK_CekiciRandevular_CekiciFirmalar_CekiciFirmaId",
                table: "CekiciRandevular");

            migrationBuilder.AlterColumn<DateTime>(
                name: "TamamlanmaTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<DateTime>(
                name: "OnayTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<int>(
                name: "CekiciFirmaId",
                table: "CekiciRandevular",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<int>(
                name: "CekiciBireyselId",
                table: "CekiciRandevular",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<DateTime>(
                name: "BaslamaTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AddForeignKey(
                name: "FK_CekiciRandevular_CekiciBireyseller_CekiciBireyselId",
                table: "CekiciRandevular",
                column: "CekiciBireyselId",
                principalTable: "CekiciBireyseller",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_CekiciRandevular_CekiciFirmalar_CekiciFirmaId",
                table: "CekiciRandevular",
                column: "CekiciFirmaId",
                principalTable: "CekiciFirmalar",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CekiciRandevular_CekiciBireyseller_CekiciBireyselId",
                table: "CekiciRandevular");

            migrationBuilder.DropForeignKey(
                name: "FK_CekiciRandevular_CekiciFirmalar_CekiciFirmaId",
                table: "CekiciRandevular");

            migrationBuilder.AlterColumn<DateTime>(
                name: "TamamlanmaTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "OnayTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "CekiciFirmaId",
                table: "CekiciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "CekiciBireyselId",
                table: "CekiciRandevular",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "BaslamaTarihi",
                table: "CekiciRandevular",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_CekiciRandevular_CekiciBireyseller_CekiciBireyselId",
                table: "CekiciRandevular",
                column: "CekiciBireyselId",
                principalTable: "CekiciBireyseller",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CekiciRandevular_CekiciFirmalar_CekiciFirmaId",
                table: "CekiciRandevular",
                column: "CekiciFirmaId",
                principalTable: "CekiciFirmalar",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
