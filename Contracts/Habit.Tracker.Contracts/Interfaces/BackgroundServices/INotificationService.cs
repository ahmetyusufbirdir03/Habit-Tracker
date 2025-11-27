using Habit.Tracker.Contracts.Dtos.BackgroundDtos;

namespace Habit.Tracker.Contracts.Interfaces.BackgroundServices;

public interface INotificationService
{
    /// <summary>
    /// Sends notification. Returns true if result is successful.
    /// </summary>
    Task<bool> SendNotificationAsync(
        IdListDto idList,
        string title, 
        string message);

    Task<bool> SendSpecialNotificationAsync(
        SpecialReminderNotificationDto specialReminder,
        string title,
        string message);
}
