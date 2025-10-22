using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.User.Register
{
    public class RegisterRequestValidator : AbstractValidator<RegisterRequestDto>
    {
        public RegisterRequestValidator()
        {
            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email adresi boş olamaz")
                .EmailAddress().WithMessage("Geçerli bir email adresi giriniz");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Şifre boş olamaz")
                .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır")
                .Matches("[A-Z]").WithMessage("Şifre en az bir büyük harf içermelidir")
                .Matches("[a-z]").WithMessage("Şifre en az bir küçük harf içermelidir")
                .Matches("[0-9]").WithMessage("Şifre en az bir rakam içermelidir");

            RuleFor(x => x.PhoneNumber)
                .NotEmpty().WithMessage("Telefon numarası boş olamaz")
                .Matches(@"^0\d{10}$")
                .WithMessage("Geçerli bir telefon numarası giriniz (örn: 05551112233)");

            RuleFor(x => x.UserName)
                .NotEmpty().WithMessage("Username boş olamaz")
                .MinimumLength(7).WithMessage("Kullanıcı adı en az 7 karakter olmalı");
        }
    }
}
