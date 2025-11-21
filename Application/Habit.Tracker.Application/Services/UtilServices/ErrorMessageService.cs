using Microsoft.Extensions.Localization;

namespace Habit.Tracker.Application.Services.UtilServices
{
    public class ErrorMessageService
    {
        private readonly IStringLocalizer<ErrorMessageService> _localizer;

        public ErrorMessageService(IStringLocalizer<ErrorMessageService> localizer)
        {
            _localizer = localizer;
        }

        // TOKEN MESSAGES
        public string TokenNotFound => _localizer["Authentication token not found"];
        public string InvalidOrExpiredToken => _localizer["Invalid or expired authentication token"];

        public string SessionExpired => _localizer["This token is expired"];

        // USER MESSAGES
        public string UserNotFound => _localizer["User not found"];
        public string EmailAlreadyRegistered => _localizer["Email address is already registered"];
        public string PhoneNumberAlreadyRegistered => _localizer["Phone number is already registered"];
        public string UsernameAlreadyTaken => _localizer["Username is already taken"];
        public string EmailNotFound => _localizer["Email address not found"];
        public string InvalidAuthenticationCredentials => _localizer["Invalid authentication credentials"];

        // USER DEVICES
        public string DeviceNotFound => _localizer["Device not found"];

        // HABIT GROUP MESSAGES
        public string HabitGroupNameAlreadyExists => _localizer["Habit group name already exists"];
        public string HabitGroupNotFound => _localizer["Habit group not found"];
        public string HabitGroupWithSameNameExists => _localizer["Another habit group with the same name already exists"];
        public string HabitGroupAlreadyExists => _localizer["Habit group already exists"];
        public string MaxGroupCount => _localizer["Max group count - 10"];

        //HABIT MESSAGES
        public string InvalidPeriodType => _localizer["Invalid period type"];
        public string HabitNotFound => _localizer["Habit not found"];
        public string HabitWithSameNameExists => _localizer["Another habit with the same name already exists"];

        //SCHEDULING MESSAGES 
        public string SchedulerNotFound => _localizer["Scheduler not found"];
        public string SchedulerAlreadyExists => _localizer["Scheduler already exists"];
        public string UnsuitableReaminderTimes => _localizer["Reminder time counts not equal to frequency"];
        public string WrongPeriodType => _localizer["Wrong Period Type"];
        public string ThisTimerAlreadyExist => _localizer["This timer already exists"];
        public string ScheduleDaysConflict => _localizer["The days are conflicts each other. Please choose unique days"];
        public string HasAlreadySchedulers => _localizer["This habit already has schedulers"];

        //SPECIAL REMINDERS
        public string MaxReminderCount => _localizer["Max reminder count - 10"];
        public string ReminderAlreadyExistsWithSameNameAndDate => _localizer["A reminder with same name and date already exists"];
        public string ReminderNotFound => _localizer["Reminder not found"];

    }
}
