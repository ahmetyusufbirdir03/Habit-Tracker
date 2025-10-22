namespace Habit.Tracker.Contracts.Dtos.User.Login;

public class LoginResponseDto
{
    public string? Token { get; set; }
    public string? RefreshToken { get; set; }
    public DateTime Expiration { get; set; }
}
