namespace Habit.Tracker.Contracts.Interfaces.JobHandlers;

public interface IDailyHandler
{
    Task CheckDailySchedulersAsync();
}
