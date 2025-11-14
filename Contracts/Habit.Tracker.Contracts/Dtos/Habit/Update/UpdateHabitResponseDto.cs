using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit.Update;

public class UpdateHabitResponseDto
{
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public DateTime StartDate { get; set; }
    public int Streak { get; set; } = 0;
    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency { get; set; }
    public bool IsActive { get; set; } = false;
    public string? Notes { get; set; }
    public string? CreatedDate { get; set; }

}
