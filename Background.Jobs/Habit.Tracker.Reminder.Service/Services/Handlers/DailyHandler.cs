using Habit.Tracker.Contracts.Dtos.BackgroundDtos;
using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Contracts.Interfaces.JobHandlers;
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
                !hd.isDoneToday &&
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
                    $"{habitName}'s time. Let's get it done!"                    
                );

                scheduler.LastNotificationDate = DateTime.Now;
            }
            await _dbContext.SaveChangesAsync();
        }
    }
}
