namespace Habit.Tracker.Contracts.Dtos.User.Update;

public class UpdateUserDto
{
    public Guid Id { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string? NewPassword { get; set; }
    public string? CurrentPassword { get; set; }
}
