using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Habit.Tracker.Reminder.Service.Jobs;

public class HabitResetHostedService : BackgroundService
{
    private readonly ILogger<HabitResetHostedService> _logger;
    private readonly IServiceScopeFactory _scopeFactory;

    public HabitResetHostedService(ILogger<HabitResetHostedService> logger, IServiceScopeFactory scopeFactory)
    {
        _logger = logger;
        _scopeFactory = scopeFactory;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("----------RESET JOB IS STARTED----------");
        while (!stoppingToken.IsCancellationRequested)
        {
            var now = DateTime.Now;
            var targetTime = now.Date.AddSeconds(10);
            if (targetTime <= now) targetTime = targetTime.AddDays(1);

            var delay = targetTime - now;
            _logger.LogInformation($"SLEEPING UNTIL {targetTime} FOR NEXT RESET.");

            await Task.Delay(delay, stoppingToken);

            try
            {
                using var scope = _scopeFactory.CreateScope();
                var resetService = scope.ServiceProvider.GetRequiredService<IHabitResetService>();
                await resetService.RunScheduledResetsAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error running scheduled reset.");
            }
        }
    }
}