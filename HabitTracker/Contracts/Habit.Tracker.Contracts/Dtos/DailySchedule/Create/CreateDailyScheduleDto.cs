namespace Habit.Tracker.Contracts.Dtos.DailyHabit.Create;

public class CreateDailyScheduleDto
{
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; } = new();
}