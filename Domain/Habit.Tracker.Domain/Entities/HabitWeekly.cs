namespace Habit.Tracker.Domain.Entities;

public class HabitWeekly : BaseEntity
{
    public Guid HabitId { get; set; }
    public DayOfWeek DayOfWeek { get; set; } 
    public TimeSpan ReminderTime { get; set; }
    public bool IsDoneToday { get; set; }

    public HabitEntity? Habit { get; set; }
}
