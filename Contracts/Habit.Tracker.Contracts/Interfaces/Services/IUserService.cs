using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.User;
using Habit.Tracker.Contracts.Dtos.User.Login;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Dtos.User.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IUserService
{
    public Task<ResponseDto<NoContentDto>> DeleteUserAsync(Guid id);
    public Task<ResponseDto<UserResponseDto>> UpdateUserAsync(UpdateUserDto request);
    public Task<ResponseDto<IList<UserResponseDto>>> GetAllUsers();
    public Task<ResponseDto<UserResponseDto>> GetUserByEmailAsync(string email);
}


