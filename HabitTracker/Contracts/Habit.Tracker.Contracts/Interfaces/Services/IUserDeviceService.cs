using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.User.Device;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IUserDeviceService
{
    Task<ResponseDto<NoContentDto>> SaveDeviceTokenAsync(SaveDeviceTokenRequestDto request);
    
    Task<ResponseDto<NoContentDto>> DeleteDeviceUserAsync(string deviceToken);
}
