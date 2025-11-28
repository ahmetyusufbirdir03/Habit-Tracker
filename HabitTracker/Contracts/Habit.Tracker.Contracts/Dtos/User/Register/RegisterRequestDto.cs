namespace Habit.Tracker.Contracts.Dtos.User.Register;

public class RegisterRequestDto 
{
    public string Email { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
}
