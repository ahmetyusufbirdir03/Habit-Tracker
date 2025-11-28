namespace Habit.Tracker.Contracts.Dtos.WeeklyScheduler;

public class WeeklySchedulerResponseDto
{
    public Guid Id { get; set; }
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; }
    public bool IsDone { get; set; }
    public DayOfWeek DayOfWeek { get; set; }
}
