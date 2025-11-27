using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Contracts.Interfaces.JobHandlers;
using Habit.Tracker.Infrustructure.Context;
using Microsoft.Extensions.Logging;

namespace Habit.Tracker.Reminder.Service.Services;

public class HabitResetService : IHabitResetService
{
    private readonly AppDbContext _dbContext;
    private readonly ILogger<HabitResetService> _logger;
    private readonly IDailyHandler _dailyHandler;      
    private readonly IWeeklyHandler _weeklyHandler;    
    private readonly IMonthlyHandler _monthlyHandler;
    private readonly ISpecialReminderHandler _specialReminder;

    public HabitResetService(
        AppDbContext dbContext, 
        ILogger<HabitResetService> logger,
        IDailyHandler dailyHandler,
        IWeeklyHandler weeklyHandler,
        IMonthlyHandler monthlyHandler,
        ISpecialReminderHandler specialReminder)
    {
        _dbContext = dbContext;
        _logger = logger;
        _dailyHandler = dailyHandler;
        _weeklyHandler = weeklyHandler;
        _monthlyHandler = monthlyHandler;
        _specialReminder = specialReminder;
    }

    public async Task RunScheduledResetsAsync()
    {
        _logger.LogInformation("----------RESET STARTED----------");
        var now = DateTime.Now;

        await _dailyHandler.ResetDailySchedulersAsync();

        if (now.DayOfWeek == DayOfWeek.Monday)
        {
            _logger.LogInformation("RESET WEEKLY SCHEDULERS AND HABITS");
            await _weeklyHandler.ResetWeeklySchedulersAsync();
        }

        if (now.Day == 1)
        {
            _logger.LogInformation("RESET MONTHLY SCHEDULERS AND HABITS");
            await _monthlyHandler.ResetMonthlySchedulersAsync();
        }

        await _dbContext.SaveChangesAsync();

        _logger.LogInformation("----------RESET FINISHED----------");
    }
}
