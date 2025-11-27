namespace Habit.Tracker.Contracts.Interfaces.JobHandlers;

public interface IWeeklyHandler
{
    Task CheckWeeklySchedulersAsync();
    Task ResetWeeklySchedulersAsync();
}
