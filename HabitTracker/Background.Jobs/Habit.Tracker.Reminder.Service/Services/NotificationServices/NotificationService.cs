using FirebaseAdmin.Messaging;
using Habit.Tracker.Contracts.Dtos.BackgroundDtos;
using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Infrustructure.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using FCMNotification = FirebaseAdmin.Messaging.Notification;

namespace Habit.Tracker.Reminder.Service.Services.NotificationServices;

public class NotificationService : INotificationService
{
    private readonly ILogger<NotificationService> _logger;
    private readonly AppDbContext _dbContext; 

    public NotificationService(ILogger<NotificationService> logger, AppDbContext dbContext)
    {
        _logger = logger;
        _dbContext = dbContext;
    }

    public async Task<bool> SendNotificationAsync(
        IdListDto idList,
        string title,
        string message)
    {

        var userDeviceTokens = await _dbContext.UserDevices
            .Where(x => x.UserId == idList.UserId && !string.IsNullOrEmpty(x.FcmToken))
            .Select(x => x.FcmToken)
            .ToListAsync();

        if (!userDeviceTokens.Any())
        {
            _logger.LogWarning($"User {idList.UserId} has no registered FCM tokens. Notification skipped.");
            return false;
        }

        var notificationLog = new Domain.Entities.Notification
        {
            Id = Guid.NewGuid(),
            Title = title,
            Message = message,
            IsSent = false, 
            RetryCount = 0,
            CreatedDate = DateTime.UtcNow,
            SchedulerId = idList.SchedulerId,
            UserId = idList.UserId
        };

        bool anySuccess = false;
        bool isSent = false;

        foreach (var token in userDeviceTokens)
        {
            var fcmMessage = new Message()
            {
                Token = token,
                Notification = new FCMNotification() 
                {
                    Title = title,
                    Body = message
                },
                Data = new Dictionary<string, string>()
                {
                    { "schedulerId", idList.SchedulerId.ToString() },
                    { "userId", idList.UserId.ToString() },
                    { "habitId", idList.HabitId.ToString() },
                    { "habitGroupId", idList.HabitGroupId.ToString() }
                }
            };

            try
            {
                isSent = await SendWithRetryAsync(fcmMessage);

                if (isSent)
                {
                    anySuccess = true;
                    _logger.LogInformation($"Notification sent to token {token.Substring(0, 5)}...");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error sending to token {token}");
            }
        }

        _logger.LogInformation($"Notification log for Scheduler {idList.SchedulerId} saved with IsSent: {anySuccess}");

        notificationLog.IsSent = anySuccess ;

        await _dbContext.Notification.AddAsync(notificationLog);

        await _dbContext.SaveChangesAsync();

        return anySuccess;
    }

    public async Task<bool> SendSpecialNotificationAsync(
        SpecialReminderNotificationDto specialReminder,
        string title,
        string message)
    {
        var userDeviceTokens = await _dbContext.UserDevices
            .Where(x => x.UserId == specialReminder.UserId && !string.IsNullOrEmpty(x.FcmToken))
            .Select(x => x.FcmToken)
            .ToListAsync();

        if (!userDeviceTokens.Any())
        {
            _logger.LogWarning($"User {specialReminder.UserId} has no registered FCM tokens. Notification skipped.");
            return false;
        }

        var notificationLog = new Domain.Entities.Notification
        {
            Id = Guid.NewGuid(),
            Title = title,
            Message = message,
            IsSent = false,
            RetryCount = 0,
            CreatedDate = DateTime.UtcNow,
            UserId = specialReminder.UserId,
            HabitGroupId = specialReminder.HabitGroupId,
        };

        bool anySuccess = false;
        bool isSent = false;

        foreach (var token in userDeviceTokens)
        {
            var fcmMessage = new Message()
            {
                Token = token,
                Notification = new FCMNotification()
                {
                    Title = title,
                    Body = message
                },
                Data = new Dictionary<string, string>()
{
                    { "userId", specialReminder.UserId.ToString() },
                    { "habitGroupId", specialReminder.HabitGroupId.ToString() },
                    { "schedulerId", Guid.Empty.ToString() },
                    { "habitId", Guid.Empty.ToString() }, 
                    { "notificationType", "special" } 
                }
            };

            try
            {
                isSent = await SendWithRetryAsync(fcmMessage);

                if (isSent)
                {
                    anySuccess = true;
                    _logger.LogInformation($"Notification sent to token {token.Substring(0, 5)}...");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error sending to token {token}");
            }
        }

        _logger.LogInformation($"Notification log for Scheduler {specialReminder.HabitGroupId} saved with IsSent: {anySuccess}");

        notificationLog.IsSent = anySuccess;

        await _dbContext.Notification.AddAsync(notificationLog);

        await _dbContext.SaveChangesAsync();

        return anySuccess;
    }

    private async Task<bool> SendWithRetryAsync(Message message)
    {
        int maxRetries = 3;
        int currentRetry = 0;

        while (currentRetry < maxRetries)
        {
            try
            {
                await FirebaseMessaging.DefaultInstance.SendAsync(message);
                return true; 
            }
            catch (Exception)
            {
                currentRetry++;
                if (currentRetry >= maxRetries) return false;
 
                await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, currentRetry)));
            }
        }
        return false;
    }
}
    