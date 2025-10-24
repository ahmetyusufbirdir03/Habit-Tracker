namespace Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Update;

public class UpdateWeeklySchedulerDto
{
    public Guid Id { get; set; }
    public DayOfWeek DayOfWeek { get; set; }
    public TimeSpan ReminderTime { get; set; }
}
