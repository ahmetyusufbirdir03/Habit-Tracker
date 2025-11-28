using Habit.Tracker.Domain.Enums;

namespace Habit.Tracker.Domain.Entities;

public class HabitEntity : BaseEntity
{
    
    public string? Name { get; set; }
    public DateTime StartDate { get; set; }
    public int Streak { get; set; } = 0;
    public int BestStreak { get; set; } = 0;

    public PeriodTypeEnum PeriodType { get; set; }
    public int Frequency {  get; set; }

    public Guid HabitGroupId { get; set; }
    public HabitGroup? HabitGroup { get; set; }


    public bool IsActive { get; set; } = false;
    public bool IsDone { get; set; } = false;
    public string? Notes { get; set; }



    public List<HabitDaily> DailySchedules { get; set; } = new();
    public List<HabitWeekly> WeeklySchedules { get; set; } = new();
    public List<HabitMonthly> MonthlySchedules { get; set; } = new();
}
