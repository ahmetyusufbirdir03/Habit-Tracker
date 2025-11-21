namespace Habit.Tracker.Contracts.Dtos.BackgroundDtos;

public class IdListDto
{
    public Guid UserId { get; set; }
    public Guid HabitId { get; set; }
    public Guid HabitGroupId { get; set; }
    public Guid SchedulerId { get; set; }
}
