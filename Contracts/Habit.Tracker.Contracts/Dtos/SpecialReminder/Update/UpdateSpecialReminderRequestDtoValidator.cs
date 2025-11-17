using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;

public class UpdateSpecialReminderRequestDtoValidator : AbstractValidator<UpdateSpecialReminderRequestDto>
{
    public UpdateSpecialReminderRequestDtoValidator()
    {
        RuleFor(x => x.Title)
          .MaximumLength(100).WithMessage("Başlık en fazla 100 karakter olabilir.");

        RuleFor(x => x.Month)
            .InclusiveBetween(1, 12)
            .WithMessage("Ay değeri 1 ile 12 arasında olmalıdır.");

        RuleFor(x => x.Day)
            .InclusiveBetween(1, 31)
            .WithMessage("Gün değeri 1 ile 31 arasında olmalıdır.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Açıklama en fazla 100 karakter olabilir.");
    }
}
