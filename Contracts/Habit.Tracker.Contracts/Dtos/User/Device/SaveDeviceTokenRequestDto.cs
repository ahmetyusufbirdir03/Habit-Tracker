namespace Habit.Tracker.Contracts.Dtos.User.Device;

public class SaveDeviceTokenRequestDto
{
    public Guid UserId { get; set; }
    public string Token { get; set; }
    public string? Platform { get; set; }
}
