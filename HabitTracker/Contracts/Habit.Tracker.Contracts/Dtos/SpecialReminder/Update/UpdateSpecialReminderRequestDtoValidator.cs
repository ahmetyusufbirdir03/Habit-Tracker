using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;

public class UpdateSpecialReminderRequestDtoValidator : AbstractValidator<UpdateSpecialReminderRequestDto>
{
    public UpdateSpecialReminderRequestDtoValidator()
    {
        RuleFor(x => x.Title)
          .NotEmpty().WithMessage("Başlık boş olamaz.")
          .MaximumLength(100).WithMessage("Başlık en fazla 100 karakter olabilir.");

        RuleFor(x => x.Month)
            .NotNull().WithMessage("Month alanı zorunludur.")
            .InclusiveBetween(1, 12).WithMessage("Ay 1 ile 12 arasında olmalıdır.");

        RuleFor(x => x.Day)
            .NotNull().WithMessage("Day alanı zorunludur.")
            .InclusiveBetween(1, 31).WithMessage("Gün 1 ile 31 arasında olmalıdır.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Açıklama en fazla 100 karakter olabilir.");

        RuleFor(x => x)
        .Must(x =>
        {
            try
            {
                var _ = new DateTime(2000, x.Month, x.Day);
                return true;
            }
            catch
            {
                return false;
            }
        })
        .WithMessage("Girdiğiniz ay ve gün kombinasyonu geçerli bir tarih değil.");

    }
}
