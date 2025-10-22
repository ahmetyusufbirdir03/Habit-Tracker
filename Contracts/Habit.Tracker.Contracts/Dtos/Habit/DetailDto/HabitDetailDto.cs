using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Contracts.Dtos.Habit.DetailDto;

public class HabitDetailDto
{
    public Guid Id { get; set; }
    public Guid HabitGroupId { get; set; }
    public string? Name { get; set; }
    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency { get; set; }
    public bool IsActive { get; set; }
    public string? Notes { get; set; }

    public List<HabitDailyDto> DailySchedules { get; set; } = new();
    public List<HabitWeeklyDto> WeeklySchedules { get; set; } = new();
    public List<HabitMonthlyDto> MonthlySchedules { get; set; } = new();
}

public class HabitDailyDto
{
    public TimeSpan ReminderTime { get; set; }
}

public class HabitWeeklyDto
{
    public string? DayOfWeek { get; set; }
    public TimeSpan ReminderTime { get; set; }
}

public class HabitMonthlyDto
{
    public int DayOfMonth { get; set; }
    public TimeSpan ReminderTime { get; set; }
}
