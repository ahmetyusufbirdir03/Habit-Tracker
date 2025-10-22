using Microsoft.Extensions.Localization;

namespace Habit.Tracker.Application.Services
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

        // USER MESSAGES
        public string UserNotFound => _localizer["User not found"];
        public string EmailAlreadyRegistered => _localizer["Email address is already registered"];
        public string PhoneNumberAlreadyRegistered => _localizer["Phone number is already registered"];
        public string UsernameAlreadyTaken => _localizer["Username is already taken"];
        public string EmailNotFound => _localizer["Email address not found"];
        public string InvalidAuthenticationCredentials => _localizer["Invalid authentication credentials"];

        // HABIT GROUP MESSAGES
        public string HabitGroupNameAlreadyExists => _localizer["Habit group name already exists"];
        public string HabitGroupNotFound => _localizer["Habit group not found"];
        public string HabitGroupWithSameNameExists => _localizer["Another habit group with the same name already exists"];
        public string HabitGroupAlreadyExists => _localizer["Habit group already exists"];

        //HABIT MESSAGES
        public string InvalidPeriodType => _localizer["Invalid period type"];
        public string HabitNotFound => _localizer["Habit not found"];
        public string HabitWithSameNameExists => _localizer["Another habit with the same name already exists"];

        //SCHEDULING MESSAGES 
        public string WrongPeriodType => _localizer["Wrong Period Type"];
        public string DailyHabitNotFound => _localizer["Daily habit not found"];
    }
}
