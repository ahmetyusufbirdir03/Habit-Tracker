namespace Habit.Tracker.Domain.Entities;

public class HabitDaily : BaseEntity
{
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; }
    public bool isDoneToday { get; set; } = false;

    public HabitEntity? Habit { get; set; }
}
