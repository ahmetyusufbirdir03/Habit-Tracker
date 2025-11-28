using Habit.Tracker.Application.Services;
using Habit.Tracker.Contracts.Dtos.Auth;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.User.Login;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers;

public class AuthController : BaseController
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost]
    public async Task<IActionResult> RefreshAccessToken(RefreshTokenDto request)
    {
        var response = await _authService.RefreshAccessTokenAsync(request);

        return StatusCode(response.StatusCode, response);
    }

    [HttpPost]
    public async Task<IActionResult> Register(RegisterRequestDto request)
    {
        var response = await _authService.RegisterAsync(request);

        return StatusCode(response.StatusCode, response);
    }

    [HttpPost]
    public async Task<IActionResult> Login(LoginRequestDto request)
    {
        var response = await _authService.LoginAsync(request);

        return StatusCode(response.StatusCode, response);
    }
}
