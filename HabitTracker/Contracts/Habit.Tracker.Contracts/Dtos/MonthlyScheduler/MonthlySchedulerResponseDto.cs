namespace Habit.Tracker.Contracts.Dtos.MonthlyScheduler;

public class MonthlySchedulerResponseDto
{
    public Guid Id { get; set; }
    public Guid HabitId { get; set; }
    public int DayOfMonth { get; set; }
    public bool IsDone { get; set; }
    public TimeSpan ReminderTime { get; set; }
    
}
