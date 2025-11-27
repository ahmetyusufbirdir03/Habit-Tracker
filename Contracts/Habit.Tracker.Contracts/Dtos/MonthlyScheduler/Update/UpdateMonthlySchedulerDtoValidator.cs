using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Update;

public class UpdateMonthlySchedulerDtoValidator : AbstractValidator<UpdateMonthlySchedulerDto>
{
    public UpdateMonthlySchedulerDtoValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty()
            .WithMessage("HabitId alanı boş olamaz.");

        RuleFor(x => x.DayOfMonth)
            .Cascade(CascadeMode.Stop)
            .InclusiveBetween(1, 28)
            .WithMessage("Ayın günü 1 ile 28 arasında olmalıdır.")
            .Must(BeValidDayForCurrentMonth)
            .WithMessage("Geçerli ay bu kadar gün içermiyor.");

        RuleFor(x => x.ReminderTime)
            .NotEmpty()
            .WithMessage("Hatırlatma zamanı belirtilmelidir.")
            .Must(time => time >= TimeSpan.Zero && time < TimeSpan.FromDays(1))
            .WithMessage("Hatırlatma zamanı 00:00 ile 23:59 arasında olmalıdır.");
    }

    private bool BeValidDayForCurrentMonth(int dayOfMonth)
    {
        var now = DateTime.Now;
        int daysInMonth = DateTime.DaysInMonth(now.Year, now.Month);
        return dayOfMonth <= daysInMonth;
    }
}

