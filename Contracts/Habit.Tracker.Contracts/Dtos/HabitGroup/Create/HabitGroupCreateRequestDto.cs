namespace Habit.Tracker.Contracts.Dtos.HabitGroup.Create;

public class HabitGroupCreateRequestDto
{
    public string? Name { get; set; }
    public Guid UserId { get; set; }

}
