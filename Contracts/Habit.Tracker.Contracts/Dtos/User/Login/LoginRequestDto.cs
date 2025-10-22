using System.ComponentModel;

namespace Habit.Tracker.Contracts.Dtos.User.Login;

public class LoginRequestDto
{
    [DefaultValue("ahmet@mail")]
    public string Email { get; set; }
    [DefaultValue("123Ahmet")]
    public string Password { get; set; }

}
