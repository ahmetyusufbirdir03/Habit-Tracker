namespace Habit.Tracker.Contracts.Dtos.DailySchedule;

public class DailyHabitResponseDto
{
    public Guid Id { get; set; }
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; }
    public bool IsDone { get; set; }
}
