namespace Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;

public class CreateWeeklySchedulerDto
{
    public Guid HabitId { get; set; }
    public List<WeeklyScheduleDto> Schedules { get; set; } = new();
}

public class WeeklyScheduleDto
{
    public DayOfWeek DayOfWeek { get; set; } 
    public TimeSpan ReminderTime { get; set; } 
}