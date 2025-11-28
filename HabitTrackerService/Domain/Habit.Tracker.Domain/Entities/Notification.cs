namespace Habit.Tracker.Domain.Entities;

public class Notification : BaseEntity
{
    public string? Title { get; set; }
    public string? Message { get; set; }
    public bool IsSent { get; set; }
    public int? RetryCount { get; set; }
    public Guid? SchedulerId { get; set; }
    public Guid? HabitGroupId { get; set; }
    public Guid UserId { get; set; }

}
