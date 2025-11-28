namespace Habit.Tracker.Domain.Entities;

public class HabitGroup : BaseEntity
{
    public string? Name { get; set; }

    public Guid UserId { get; set; }
    public User? User { get; set; }

    public List<HabitEntity>? Habits { get; set; }
    public List<SpecialReminder>? SpecialReminders { get; set; }
}
