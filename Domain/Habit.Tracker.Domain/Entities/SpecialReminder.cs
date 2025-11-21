namespace Habit.Tracker.Domain.Entities;

public class SpecialReminder
{
    public Guid Id { get; set; }
    public string? Title { get; set; }
    public int Month { get; set; }
    public int Day { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastNotificationDate { get; set; }

    public Guid HabitGroupId { get; set; }
    public HabitGroup HabitGroup { get; set; }
    
}
