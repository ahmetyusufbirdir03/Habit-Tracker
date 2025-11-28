using Habit.Tracker.Contracts.Dtos.BackgroundDtos;
using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Contracts.Interfaces.JobHandlers;
using Habit.Tracker.Domain.Enums;
using Habit.Tracker.Infrustructure.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Habit.Tracker.Reminder.Service.Services.Handlers;

public class DailyHandler : IDailyHandler   
{
    private AppDbContext _dbContext;
    private readonly ILogger<DailyHandler> _logger;
    private readonly INotificationService _notificationService;

    public DailyHandler(
        AppDbContext dbContext, 
        ILogger<DailyHandler> logger, 
        INotificationService notificationService)
    {
        _dbContext = dbContext;
        _logger = logger;
        _notificationService = notificationService;
    }
    public async Task CheckDailySchedulersAsync()
    {
        _logger.LogInformation("Daily Scheduler Tablosuna bakılıyor");
        var now = DateTime.Now;
        var currentTime = now.TimeOfDay;

        var startTimeWindow = currentTime.Subtract(TimeSpan.FromMinutes(2));

        var pendingSchedulers = await _dbContext.HabitDaily
            .Include(x => x.Habit)
                .ThenInclude(h => h.HabitGroup)
            .Where(hd =>
                !hd.IsDone &&
                hd.Habit!.IsActive && 
                hd.ReminderTime >= startTimeWindow &&
                hd.ReminderTime <= currentTime &&
                (hd.LastNotificationDate == null || hd.LastNotificationDate.Value.Date != now.Date)
            )
            .ToListAsync();
        if (pendingSchedulers.Any())
        {
            _logger.LogInformation($"{pendingSchedulers.Count} adet gönderilecek bildirim bulundu.");

            foreach (var scheduler in pendingSchedulers)
            {
                var userId = scheduler.Habit!.HabitGroup!.UserId!;
                var habitGroupId = scheduler.Habit!.HabitGroup!.Id;
                var habitId = scheduler.Habit!.Id;
                var habitName = scheduler.Habit!.Name;

                IdListDto idList = new IdListDto
                {
                    UserId = userId,
                    HabitId = habitId,
                    SchedulerId = scheduler.Id,
                    HabitGroupId = habitGroupId,
                };

                await _notificationService.SendNotificationAsync(
                    idList,
                    "The Time Has Come! ⏰",
                    $"Reminder: {habitName} at {scheduler.ReminderTime.ToString(@"hh\:mm")}. Let's get it done!"              
                );

                scheduler.LastNotificationDate = DateTime.Now;
            }
            await _dbContext.SaveChangesAsync();
        }
    }

    public async Task ResetDailySchedulersAsync()
    {
        _logger.LogInformation("ResetDailySchedulersAsync()");
        var habits = await _dbContext.Habits
                .Include(h => h.DailySchedules) 
                .Where(h  => h.PeriodType == PeriodTypeEnum.Daily)
                .ToListAsync();

        if (!habits.Any()) return;

        foreach (var habit in habits)
        {
            if (!habit.IsDone)
            {
                if (habit.Streak > 0)
                {
                    _logger.LogInformation("Daily Streak Reset");
                    habit.Streak = 0;
                }
            }

            habit.IsDone = false;

            if (habit.DailySchedules != null)
            {
                foreach (var scheduler in habit.DailySchedules)
                {
                    _logger.LogInformation("Daily Scheduler isDone Reset");
                    scheduler.IsDone = false;
                }
            }
        }
    }
}
