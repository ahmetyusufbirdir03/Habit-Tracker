using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit.Update;

public class UpdateHabitRequestDto
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public PeriodTypeEnum? PeriodType { get; set; }
    public int? Frequency { get; set; }
    public string? Notes { get; set; }
}
