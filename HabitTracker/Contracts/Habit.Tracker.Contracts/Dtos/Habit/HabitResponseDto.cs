using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit;

public class HabitResponseDto
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public DateTime StartDate { get; set; }
    public int Streak { get; set; }
    public int BestStreak { get; set; }
    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency { get; set; }
    public bool IsDone { get; set; }
    public bool IsActive { get; set; } = false;
    public string? Notes { get; set; }
    public DateTime CreatedDate { get; set; }
}
