namespace Habit.Tracker.Reminder.Service.Cron;

public class CronFactory
{
    /// <summary>
    /// Daily scheduler's cron string 
    /// </summary>
    public static string GetDailyCron(TimeSpan time)
    {
        // Minute Hour * * *  -> Works at same time every day
        return $"{time.Minutes} {time.Hours} * * *";
    }

    /// <summary>
    /// Weekly scheduler's cron string 
    /// </summary>
    /// <param name="time">Reminder Time</param>
    /// <param name="dayOfWeek">0=Sunday, 1=Monday,...</param>
    public static string GetWeeklyCron(TimeSpan time, DayOfWeek dayOfWeek)
    {
        return $"{time.Minutes} {time.Hours} * * {(int)dayOfWeek}";
    }

    /// <summary>
    /// Monthly scheduler's cron string 
    /// </summary>
    /// <param name="time">Reminder Time</param>
    /// <param name="dayOfMonth">Day of month 1-31</param>
    public static string GetMonthlyCron(TimeSpan time, int dayOfMonth)
    {
        return $"{time.Minutes} {time.Hours} {dayOfMonth} * *";
    }
}
