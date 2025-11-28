namespace Habit.Tracker.Contracts.Dtos.HabitGroup.Update;

public class UpdateHabitGroupRequestDto
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
}
