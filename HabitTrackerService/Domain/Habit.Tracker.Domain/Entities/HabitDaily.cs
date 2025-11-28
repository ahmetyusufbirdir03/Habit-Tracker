namespace Habit.Tracker.Domain.Entities;

public class HabitDaily : BaseEntity
{
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; }
    public bool IsDone { get; set; } = false;
    public HabitEntity? Habit { get; set; }
    public DateTime? LastNotificationDate { get; set; }
}
