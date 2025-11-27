using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.User.Device;

public class SaveDeviceTokenRequestDtoValiator : AbstractValidator<SaveDeviceTokenRequestDto>
{
    public SaveDeviceTokenRequestDtoValiator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty().WithMessage("UserId cannot be empty.");

        RuleFor(x => x.Token)
            .NotEmpty().WithMessage("FCM token cannot be empty.")
            .MinimumLength(20).WithMessage("FCM token is too short.")
            .Matches("^[A-Za-z0-9:_\\-]+$")
            .WithMessage("FCM token contains invalid characters.");

        RuleFor(x => x.Platform)
            .Must(p => p == null || p.ToLower() is "ios" or "android" or "web")
            .WithMessage("Platform must be iOS or Android.");
    }
}
