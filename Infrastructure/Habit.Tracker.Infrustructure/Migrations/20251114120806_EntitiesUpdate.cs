using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Habit.Tracker.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class EntitiesUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsDoneToday",
                table: "habit_weekly_schedules",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsDoneToday",
                table: "habit_monthly",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateTable(
                name: "SpecialReminders",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: true),
                    Month = table.Column<int>(type: "int", nullable: false),
                    Day = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    HabitGroupId = table.Column<Guid>(type: "uniqueidentifier", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SpecialReminders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SpecialReminders_habit_groups_HabitGroupId",
                        column: x => x.HabitGroupId,
                        principalTable: "habit_groups",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SpecialReminders_HabitGroupId",
                table: "SpecialReminders",
                column: "HabitGroupId");

            migrationBuilder.CreateIndex(
                name: "IX_SpecialReminders_Month_Day",
                table: "SpecialReminders",
                columns: new[] { "Month", "Day" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SpecialReminders");

            migrationBuilder.DropColumn(
                name: "IsDoneToday",
                table: "habit_weekly_schedules");

            migrationBuilder.DropColumn(
                name: "IsDoneToday",
                table: "habit_monthly");
        }
    }
}
