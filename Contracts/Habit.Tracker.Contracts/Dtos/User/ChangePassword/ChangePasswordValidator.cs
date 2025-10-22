using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.User.ChangePassword;

public class ChangePasswordValidator : AbstractValidator<ChangePasswordRequestDto>
{
    public ChangePasswordValidator()
    {
        
    }
}
