using AutoMapper;
using Habit.Tracker.Contracts.Dtos.BackgroundDtos;
using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Contracts.Interfaces.JobHandlers;
using Habit.Tracker.Domain.Enums;
using Habit.Tracker.Infrustructure.Context;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Habit.Tracker.Reminder.Service.Services.Handlers;

public class SpecialReminderHandler : ISpecialReminderHandler
{
    private AppDbContext _dbContext;
    private readonly ILogger<DailyHandler> _logger;
    private readonly INotificationService _notificationService;
    private IMapper _mapper;

    public SpecialReminderHandler(
        AppDbContext dbContext,
        ILogger<DailyHandler> logger,
        INotificationService notificationService,
        IMapper mapper)
    {
        _dbContext = dbContext;
        _logger = logger;
        _notificationService = notificationService;
        _mapper = mapper;
    }

    public async Task CheckSpecialReminders()
    {
        _logger.LogInformation("Special Reminders Tablosuna bakılıyor");
        var now = DateTime.Now;

        var pendingReminders = await _dbContext.SpecialReminder
            .Include(x => x.HabitGroup)
                .ThenInclude(h => h.SpecialReminders)
            .Where(hd =>
                hd.Day == now.Day &&
                hd.Month == now.Month &&
                (hd.LastNotificationDate == null || hd.LastNotificationDate.Value.Date != now.Date)
            )
            .ToListAsync();

        if (pendingReminders.Any())
        {
            _logger.LogInformation($"{pendingReminders.Count} adet gönderilecek bildirim bulundu.");

            foreach (var reminder in pendingReminders)
            {
                string formattedDate = new DateTime(DateTime.Now.Year, reminder.Month, reminder.Day)
                    .ToString("dd MMM");

                var specialReminder = _mapper.Map<SpecialReminderNotificationDto>(reminder);
                specialReminder.UserId = reminder.HabitGroup.UserId;
                await _notificationService.SendSpecialNotificationAsync(
                    specialReminder,
                    "The Time Has Come! ⏰",
                    $"Special Reminder: {reminder.Title} on {formattedDate}. Dont forget about it!" +
                    $"\n {reminder.Description}"
                );

                reminder.LastNotificationDate = DateTime.Now;
            }
            await _dbContext.SaveChangesAsync();
        }
    }
}
