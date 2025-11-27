using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos;

public class CompleteSchedulerDto
{
    public Guid SchedulerId { get; set; }
    public PeriodTypeEnum PeriodType { get; set; }
}
