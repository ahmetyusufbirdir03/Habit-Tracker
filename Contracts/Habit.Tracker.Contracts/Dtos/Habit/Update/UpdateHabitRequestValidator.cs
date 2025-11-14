using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.Habit.Update;

public class UpdateHabitRequestValidator : AbstractValidator<UpdateHabitRequestDto>
{
    public UpdateHabitRequestValidator()
    {
        RuleFor(x => x.Name)
           .NotEmpty().WithMessage("Alışkanlık adı boş olamaz")
           .MaximumLength(20).WithMessage("Alışkanlık adı en fazla 200 karakter olabilir");

        RuleFor(x => x.PeriodType)
            .IsInEnum().WithMessage("Geçersiz periyot tipi");

        RuleFor(x => x.Frequency)
            .NotNull().WithMessage("Frekans boş olamaz")
            .GreaterThan(0).WithMessage("Frekans 0’dan büyük olmalıdır")
            .LessThanOrEqualTo(6).WithMessage("Frekans 7’den küçük olmalıdır");

        RuleFor(x => x.Notes)
            .MaximumLength(100).WithMessage("Notlar en fazla 100 karakter olabilir")
            .When(x => !string.IsNullOrWhiteSpace(x.Notes));
    }
}

