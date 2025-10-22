using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.HabitGroup.Update;

public class UpdateHabitGroupRequestValidator : AbstractValidator<UpdateHabitGroupRequestDto>
{
    public UpdateHabitGroupRequestValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty().WithMessage("Grup id boş olamaz");

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Grup ismi boş olamaz")
            .MaximumLength(20).WithMessage("Grup ismi en fazla 20 karakter olabilir");
    }
}
