using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.Auth;
using Habit.Tracker.Contracts.Dtos.User.Login;
using Habit.Tracker.Contracts.Dtos.User.Register;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IAuthService
{
    public Task<ResponseDto<RefreshTokenResponseDto>> RefreshAccessTokenAsync(RefreshTokenDto request);

    public Task<ResponseDto<RegisterResponseDto>> RegisterAsync(RegisterRequestDto request);
    public Task<ResponseDto<LoginResponseDto>> LoginAsync(LoginRequestDto request);
}
