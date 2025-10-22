using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit.Create;

public class CreateHabitRequestDto
{
    public string? Name { get; set; }
    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency { get; set; }
    public Guid HabitGroupId { get; set; }
    public string? Notes { get; set; }
}