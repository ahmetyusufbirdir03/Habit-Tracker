namespace Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;

public class CreateMonthlySchedulerDto
{
    public Guid HabitId { get; set; }
    public List<MonthlyScheduleDto> Schedules { get; set; } = new();
}
public class MonthlyScheduleDto
{
    public int DayOfMonth { get; set; }
    public TimeSpan ReminderTime { get; set; }
}