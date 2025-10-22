using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.HabitGroup.Create;

public class HabitGroupCreateRequestValidator : AbstractValidator<HabitGroupCreateRequestDto>
{
    public HabitGroupCreateRequestValidator()
    {
        RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Grup adı boş olamaz");
        RuleFor(x => x.UserId)
                .NotEmpty().WithMessage("Geçerli kullanıcı olmak zorunda");
    }
}
