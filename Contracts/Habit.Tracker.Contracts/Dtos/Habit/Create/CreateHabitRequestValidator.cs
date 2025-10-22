using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.Habit.Create;

public class CreateHabitRequestValidator : AbstractValidator<CreateHabitRequestDto> 
{
    public CreateHabitRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Alışkanlık adı boş olamaz")
            .MaximumLength(20).WithMessage("Alışkanlık adı en fazla 200 karakter olabilir");

        RuleFor(x => x.PeriodType)
            .IsInEnum().WithMessage("Geçersiz periyot tipi");

        RuleFor(x => x.Frequency)
            .GreaterThan(0).WithMessage("Frekans 0’dan büyük olmalıdır");

        RuleFor(x => x.HabitGroupId)
            .NotEmpty().WithMessage("HabitGroupId boş olamaz");

        RuleFor(x => x.Notes)
            .MaximumLength(100).WithMessage("Notlar en fazla 100 karakter olabilir")
            .When(x => !string.IsNullOrWhiteSpace(x.Notes));
    }
}
