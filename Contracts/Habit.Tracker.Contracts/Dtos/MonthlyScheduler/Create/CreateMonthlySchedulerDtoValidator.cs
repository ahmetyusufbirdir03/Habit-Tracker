using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;

public class CreateMonthlySchedulerDtoValidator :AbstractValidator<CreateMonthlySchedulerDto>
{
    public CreateMonthlySchedulerDtoValidator()
    {
        RuleFor(x => x.HabitId)
            .NotEmpty()
            .WithMessage("HabitId alanı boş olamaz.");

        RuleFor(x => x.Schedules)
            .NotNull()
            .WithMessage("Schedules listesi boş olamaz.")
            .NotEmpty()
            .WithMessage("En az bir plan girilmelidir.");

        RuleForEach(x => x.Schedules)
            .SetValidator(new MonthlyScheduleDtoValidator());
    }
}

public class MonthlyScheduleDtoValidator : AbstractValidator<MonthlyScheduleDto>
{
    public MonthlyScheduleDtoValidator()
    {
        RuleFor(x => x.DayOfMonth)
            .Cascade(CascadeMode.Stop)
            .InclusiveBetween(1, 28)
            .WithMessage("Ayın günü 1 ile 28 arasında olmalıdır.");

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