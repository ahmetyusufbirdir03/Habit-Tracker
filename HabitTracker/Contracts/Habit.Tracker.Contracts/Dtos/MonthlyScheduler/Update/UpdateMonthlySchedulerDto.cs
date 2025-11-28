namespace Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Update;

public class UpdateMonthlySchedulerDto
{
    public Guid Id { get; set; }
    public int DayOfMonth { get; set; }
    public TimeSpan ReminderTime { get; set; }
}
