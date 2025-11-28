namespace Habit.Tracker.Contracts.Interfaces.JobHandlers;

public interface IMonthlyHandler
{
    Task CheckMonthlySchedulersAsync();
    Task ResetMonthlySchedulersAsync();
}
