namespace Habit.Tracker.Contracts.Dtos.SpecialReminder;

public class SpecialReminderResponseDto
{
    public Guid Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public int Day {  get; set; }
    public int Month { get; set; }
}
