namespace Habit.Tracker.Contracts.Interfaces.BackgroundServices;

public interface IHabitResetService
{
    /// <summary>
    /// Triggers necessary resets based on date (Daily, Weekly, Monthly)
    /// </summary>
    Task RunScheduledResetsAsync();
}
