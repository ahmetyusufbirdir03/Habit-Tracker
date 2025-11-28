namespace Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;

public class UpdateSpecialReminderRequestDto
{
    public Guid Id { get; set; }
    public string? Title { get; set; }
    public int Month { get; set; }
    public int Day { get; set; }
    public string? Description { get; set; }
}
