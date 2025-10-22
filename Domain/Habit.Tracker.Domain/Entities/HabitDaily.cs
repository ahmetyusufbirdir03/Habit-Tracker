namespace Habit.Tracker.Domain.Entities;

public class HabitDaily : BaseEntity
{
    public Guid HabitId { get; set; }
    public TimeSpan ReminderTime { get; set; }

    public HabitEntity? Habit { get; set; }
}
