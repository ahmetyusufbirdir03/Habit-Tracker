using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;

public class CreateWeeklySchedulerValidator : AbstractValidator<CreateWeeklySchedulerDto>
{
    public CreateWeeklySchedulerValidator()
    {
        RuleFor(x => x.HabitId)
           .NotEmpty()
           .WithMessage("Habit ID boş olamaz.");

        RuleFor(x => x.Schedules)
            .NotEmpty()
            .WithMessage("En az bir gün ve saat seçmelisiniz.");

        RuleForEach(x => x.Schedules).ChildRules(schedule =>
        {
            schedule.RuleFor(s => s.DayOfWeek)
                .IsInEnum()
                .WithMessage("Geçerli bir gün seçmelisiniz.");

            schedule.RuleFor(s => s.ReminderTime)
                .NotEqual(TimeSpan.Zero)
                .WithMessage("Hatırlatma saati geçerli olmalıdır.");
        });

        RuleFor(x => x.Schedules)
            .Must(schedules =>
            {
                var uniqueDays = schedules.Select(s => s.DayOfWeek).Distinct().Count();
                return uniqueDays == schedules.Count;
            })
            .WithMessage("Aynı gün birden fazla kez seçilemez.");
    }
}

