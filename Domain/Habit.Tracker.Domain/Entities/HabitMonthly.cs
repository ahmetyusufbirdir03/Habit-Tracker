namespace Habit.Tracker.Domain.Entities;
public class HabitMonthly : BaseEntity
{
    public Guid HabitId { get; set; }
    public int DayOfMonth { get; set; }  
    public TimeSpan ReminderTime { get; set; }
    public bool IsDone { get; set; }
    public HabitEntity? Habit { get; set; }

    public DateTime? LastNotificationDate { get; set; }
}
