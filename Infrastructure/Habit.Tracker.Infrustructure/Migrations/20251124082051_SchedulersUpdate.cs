using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Habit.Tracker.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SchedulersUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsDoneToday",
                table: "habit_weekly_schedules",
                newName: "IsDone");

            migrationBuilder.RenameColumn(
                name: "IsDoneToday",
                table: "habit_monthly",
                newName: "IsDone");

            migrationBuilder.RenameColumn(
                name: "isDoneToday",
                table: "habit_daily_schedules",
                newName: "IsDone");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsDone",
                table: "habit_weekly_schedules",
                newName: "IsDoneToday");

            migrationBuilder.RenameColumn(
                name: "IsDone",
                table: "habit_monthly",
                newName: "IsDoneToday");

            migrationBuilder.RenameColumn(
                name: "IsDone",
                table: "habit_daily_schedules",
                newName: "isDoneToday");
        }
    }
}
