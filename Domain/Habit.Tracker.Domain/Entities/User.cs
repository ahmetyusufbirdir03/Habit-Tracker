using Microsoft.AspNetCore.Identity;

namespace Habit.Tracker.Domain.Entities;

public class User : IdentityUser<Guid>
{
    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpiryTime { get; set; }

}
