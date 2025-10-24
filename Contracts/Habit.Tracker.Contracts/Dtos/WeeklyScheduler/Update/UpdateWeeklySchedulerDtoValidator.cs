using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Update;

public class UpdateWeeklySchedulerDtoValidator : AbstractValidator<UpdateWeeklySchedulerDto>
{
    public UpdateWeeklySchedulerDtoValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty()
            .WithMessage("Id alanı boş olamaz.");

        RuleFor(x => x.DayOfWeek)
            .IsInEnum()
            .WithMessage("Geçerli bir gün seçilmelidir.");

        RuleFor(x => x.ReminderTime)
            .NotEmpty()
            .WithMessage("Hatırlatma zamanı belirtilmelidir.")
            .Must(time => time >= TimeSpan.Zero && time < TimeSpan.FromDays(1))
            .WithMessage("Hatırlatma zamanı 00:00 ile 23:59 arasında olmalıdır.");

    }
}
