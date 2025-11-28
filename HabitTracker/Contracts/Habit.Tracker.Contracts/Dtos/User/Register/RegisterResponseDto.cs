namespace Habit.Tracker.Contracts.Dtos.User.Register;

public class RegisterResponseDto
{
    public string? Token { get; set; }
    public string? RefreshToken { get; set; }
    public DateTime Expiration { get; set; }
}
