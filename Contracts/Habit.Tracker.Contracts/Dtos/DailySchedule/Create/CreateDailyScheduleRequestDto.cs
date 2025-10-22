namespace Habit.Tracker.Contracts.Dtos.DailyHabit.Create;

public class CreateDailyScheduleRequestDto
{
    public Guid HabitId { get; set; }
    public List<TimeSpan> ReminderTimes { get; set; } = new();
}
