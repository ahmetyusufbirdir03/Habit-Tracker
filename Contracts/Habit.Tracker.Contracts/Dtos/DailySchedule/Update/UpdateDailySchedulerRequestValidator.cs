using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.DailySchedule.Update;

public class UpdateDailySchedulerRequestValidator : AbstractValidator<UpdateDailySchedulerRequestDto>
{
    public UpdateDailySchedulerRequestValidator()
    {
        RuleFor(x => x.Id).NotEmpty().WithMessage("Zamanlayıcı id boş olmaz");
        RuleFor(x => x.ReminderTime).NotEmpty().WithMessage("Zaman değeri boş olamaz");
    }
}
