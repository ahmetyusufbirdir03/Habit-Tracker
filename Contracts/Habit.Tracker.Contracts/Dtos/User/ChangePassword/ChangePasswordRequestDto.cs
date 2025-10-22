namespace Habit.Tracker.Contracts.Dtos.User.ChangePassword;

public class ChangePasswordRequestDto
{
    public string? Email { get; set; }
    public string? Password { get; set; }
    public string? ConfirmPassword { get; set; }
}
