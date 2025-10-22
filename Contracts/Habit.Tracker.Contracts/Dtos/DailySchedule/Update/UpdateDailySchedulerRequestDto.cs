namespace Habit.Tracker.Contracts.Dtos.DailySchedule.Update;

public class UpdateDailySchedulerRequestDto
{
    public Guid Id { get; set; }
    public TimeSpan ReminderTime { get; set; }
}
