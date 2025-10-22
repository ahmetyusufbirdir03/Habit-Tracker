using FluentValidation;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;

namespace Habit.Tracker.Contracts.Dtos.DailySchedule.Create;

public class CreateDailySchedulerRequestValidator : AbstractValidator<CreateDailyScheduleRequestDto>
{
    public CreateDailySchedulerRequestValidator()
    {
        RuleFor(x => x.ReminderTimes)
            .NotEmpty().WithMessage("Determine your schedules")
            .Must(times => times.Distinct().Count() == times.Count)
            .WithMessage("Zamanlar birbirindenfarklı olmalı");

        RuleFor(x => x.HabitId).NotNull().WithMessage("Need Habit Id");
            
    }
}
