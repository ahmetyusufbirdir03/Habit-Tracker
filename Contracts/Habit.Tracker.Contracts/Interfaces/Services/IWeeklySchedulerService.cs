using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IWeeklySchedulerService
{
    public Task<ResponseDto<NoContentDto>> CreateWeeklySchedulerAsync(CreateWeeklySchedulerDto request);
    public Task<ResponseDto<NoContentDto>> UpdateWeeklySchedulerAsync();
    public Task<ResponseDto<IList<WeeklySchedulerResponseDto>>> GetWeeklySchedulersAsync(Guid habitId);
    public Task<ResponseDto<NoContentDto>> ClearWeeklySchedulersAsync(Guid habitId);
}
