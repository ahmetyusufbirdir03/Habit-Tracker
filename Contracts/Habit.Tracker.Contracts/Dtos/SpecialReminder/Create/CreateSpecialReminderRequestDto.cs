namespace Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;

public class CreateSpecialReminderRequestDto
{
    public Guid HabitGroupId { get; set; }
    public string? Title { get; set; }
    public int Month { get; set; }
    public int Day { get; set; }
    public string? Description { get; set; }
}
