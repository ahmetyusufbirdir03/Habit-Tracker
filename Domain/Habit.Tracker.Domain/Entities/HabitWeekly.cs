namespace Habit.Tracker.Domain.Entities;

public class HabitWeekly : BaseEntity
{
    public Guid HabitId { get; set; }
    public string? DayOfWeek { get; set; } 
    public TimeSpan ReminderTime { get; set; }

    public HabitEntity? Habit { get; set; }
}
