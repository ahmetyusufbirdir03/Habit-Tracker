using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Habit.Tracker.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class EntitiyUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "CompletedDaysCount",
                table: "habits",
                newName: "Streak");

            migrationBuilder.AddColumn<bool>(
                name: "isDoneToday",
                table: "habit_daily_schedules",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "isDoneToday",
                table: "habit_daily_schedules");

            migrationBuilder.RenameColumn(
                name: "Streak",
                table: "habits",
                newName: "CompletedDaysCount");
        }
    }
}
