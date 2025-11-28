using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Habit.Tracker.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class DbUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_habits_PeriodType_PeriodTypeId",
                table: "habits");

            migrationBuilder.DropTable(
                name: "PeriodType");

            migrationBuilder.DropIndex(
                name: "IX_habit_weekly_schedules_HabitId_DayOfWeek_Sequence",
                table: "habit_weekly_schedules");

            migrationBuilder.DropIndex(
                name: "IX_habit_daily_schedules_HabitId_Sequence",
                table: "habit_daily_schedules");

            migrationBuilder.DropColumn(
                name: "Sequence",
                table: "habit_weekly_schedules");

            migrationBuilder.DropColumn(
                name: "Sequence",
                table: "habit_monthly");

            migrationBuilder.DropColumn(
                name: "Sequence",
                table: "habit_daily_schedules");

            migrationBuilder.RenameColumn(
                name: "PeriodTypeId",
                table: "habits",
                newName: "PeriodType");

            migrationBuilder.RenameIndex(
                name: "IX_habits_PeriodTypeId",
                table: "habits",
                newName: "IX_habits_PeriodType");

            migrationBuilder.AddColumn<int>(
                name: "Frequency",
                table: "habits",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_habit_weekly_schedules_HabitId_DayOfWeek_ReminderTime",
                table: "habit_weekly_schedules",
                columns: new[] { "HabitId", "DayOfWeek", "ReminderTime" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_habit_weekly_schedules_HabitId_DayOfWeek_ReminderTime",
                table: "habit_weekly_schedules");

            migrationBuilder.DropColumn(
                name: "Frequency",
                table: "habits");

            migrationBuilder.RenameColumn(
                name: "PeriodType",
                table: "habits",
                newName: "PeriodTypeId");

            migrationBuilder.RenameIndex(
                name: "IX_habits_PeriodType",
                table: "habits",
                newName: "IX_habits_PeriodTypeId");

            migrationBuilder.AddColumn<int>(
                name: "Sequence",
                table: "habit_weekly_schedules",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Sequence",
                table: "habit_monthly",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Sequence",
                table: "habit_daily_schedules",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "PeriodType",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Type = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PeriodType", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_habit_weekly_schedules_HabitId_DayOfWeek_Sequence",
                table: "habit_weekly_schedules",
                columns: new[] { "HabitId", "DayOfWeek", "Sequence" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_habit_daily_schedules_HabitId_Sequence",
                table: "habit_daily_schedules",
                columns: new[] { "HabitId", "Sequence" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_habits_PeriodType_PeriodTypeId",
                table: "habits",
                column: "PeriodTypeId",
                principalTable: "PeriodType",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
