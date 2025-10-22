using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.User.Update;

public class UpdateUserValidator : AbstractValidator<UpdateUserDto>
{
    public UpdateUserValidator()
    {
        RuleFor(x => x.Email)
               .EmailAddress().WithMessage("Geçerli bir email adresi giriniz")
               .When(x => !string.IsNullOrWhiteSpace(x.Email));

        RuleFor(x => x.NewPassword)
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır")
            .Matches("[A-Z]").WithMessage("Şifre en az bir büyük harf içermelidir")
            .Matches("[a-z]").WithMessage("Şifre en az bir küçük harf içermelidir")
            .Matches("[0-9]").WithMessage("Şifre en az bir rakam içermelidir")
            .NotEqual(x => x.CurrentPassword)
                .WithMessage("Yeni şifre eskisiyle aynı olamaz")
            .When(x => !string.IsNullOrWhiteSpace(x.NewPassword));

        RuleFor(x => x.CurrentPassword)
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır")
            .Matches("[A-Z]").WithMessage("Şifre en az bir büyük harf içermelidir")
            .Matches("[a-z]").WithMessage("Şifre en az bir küçük harf içermelidir")
            .Matches("[0-9]").WithMessage("Şifre en az bir rakam içermelidir")
            .When(x => !string.IsNullOrWhiteSpace(x.NewPassword));

        RuleFor(x => x.PhoneNumber)
            .Matches(@"^0\d{10}$")
            .WithMessage("Geçerli bir telefon numarası giriniz (örn: 05551112233)")
            .When(x => !string.IsNullOrWhiteSpace(x.PhoneNumber));

        RuleFor(x => x.Username)
            .MinimumLength(7).WithMessage("Kullanıcı adı en az 7 karakter olmalı")
            .When(x => !string.IsNullOrWhiteSpace(x.Username));
    }
}
