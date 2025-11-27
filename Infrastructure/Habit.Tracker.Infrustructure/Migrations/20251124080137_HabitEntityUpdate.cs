using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Habit.Tracker.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class HabitEntityUpdate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsDone",
                table: "habits",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsDone",
                table: "habits");
        }
    }
}
