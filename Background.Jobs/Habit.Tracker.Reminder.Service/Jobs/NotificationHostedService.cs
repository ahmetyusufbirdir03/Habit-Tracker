using Habit.Tracker.Contracts.Interfaces.JobHandlers;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Habit.Tracker.Reminder.Service.Jobs;

public class NotificationHostedService : BackgroundService
{
    private ILogger<NotificationHostedService> _logger;
    private readonly IServiceScopeFactory _scopeFactory;

    public NotificationHostedService(ILogger<NotificationHostedService> logger,
        IServiceScopeFactory scopeFactory)
    {
        _logger = logger;
        _scopeFactory = scopeFactory;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var _dailyHandler = scope.ServiceProvider.GetRequiredService<IDailyHandler>();
                await _dailyHandler.CheckDailySchedulersAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking daily reminders");
            }

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }

}
