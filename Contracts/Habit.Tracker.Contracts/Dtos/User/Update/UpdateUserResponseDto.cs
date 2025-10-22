namespace Habit.Tracker.Contracts.Dtos.User.Update;

public class UpdateUserResponseDto
{
    public string? Token { get; set; }
    public string? RefreshToken { get; set; }
    public DateTime? Expiration { get; set; }
}
