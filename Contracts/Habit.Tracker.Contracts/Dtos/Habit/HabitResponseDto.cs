using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit;

public class HabitResponseDto
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public DateTime StartDate { get; set; }
    public int CompletedDaysCount { get; set; }
    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency { get; set; }
    public Guid HabitGroupId { get; set; }
    public bool IsActive { get; set; } = false;
    public string? Notes { get; set; }
}
