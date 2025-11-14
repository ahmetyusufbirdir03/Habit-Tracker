namespace Habit.Tracker.Contracts.Dtos.Auth;

public class RefreshTokenResponseDto
{
    public string AccessToken { get; set; }
    public string RefreshToken { get; set; }
    public DateTime ExpirationTime { get; set; }
}
