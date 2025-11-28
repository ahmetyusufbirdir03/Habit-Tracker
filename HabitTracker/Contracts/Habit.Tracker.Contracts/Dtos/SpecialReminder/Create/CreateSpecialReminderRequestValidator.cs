using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;

public class CreateSpecialReminderRequestValidator : AbstractValidator<CreateSpecialReminderRequestDto>
{
    public CreateSpecialReminderRequestValidator()
    {
        RuleFor(x => x.HabitGroupId)
            .NotEmpty().WithMessage("Habit group seçimi zorunludur.");

        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Başlık boş olamaz.")
            .MaximumLength(100).WithMessage("Başlık en fazla 100 karakter olabilir.");

        RuleFor(x => x.Month)
            .NotNull().WithMessage("Month alanı zorunludur.")
            .InclusiveBetween(1, 12).WithMessage("Ay 1 ile 12 arasında olmalıdır.");

        RuleFor(x => x.Day)
            .NotNull().WithMessage("Day alanı zorunludur.")
            .InclusiveBetween(1, 31).WithMessage("Gün 1 ile 31 arasında olmalıdır.");



        RuleFor(x => x)
        .Must(x =>
        {
            if (!x.Month.HasValue || !x.Day.HasValue) return true; 
            try
            {
                var _ = new DateTime(2000, x.Month.Value, x.Day.Value);
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