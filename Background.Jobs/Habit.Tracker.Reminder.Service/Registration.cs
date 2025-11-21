using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Habit.Tracker.Contracts.Interfaces.BackgroundServices;
using Habit.Tracker.Contracts.Interfaces.JobHandlers;
using Habit.Tracker.Reminder.Service.Jobs;
using Habit.Tracker.Reminder.Service.Services.Handlers;
using Habit.Tracker.Reminder.Service.Services.NotificationServices;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Habit.Tracker.Reminder.Service;

public static class Registration
{

    public static void AddBackgroundJobs(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddHostedService<NotificationHostedService>();
        services.AddScoped(typeof(IDailyHandler), typeof(DailyHandler));
        services.AddScoped(typeof(INotificationService), typeof(NotificationService));

        string basePath = AppDomain.CurrentDomain.BaseDirectory;

        string jsonPath = Path.Combine(basePath, "firebase-config.json");

        FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromFile(jsonPath)
            }
        );


    }
}
