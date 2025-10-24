using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IWeeklySchedulerService
{
    public Task<ResponseDto<NoContentDto>> CreateWeeklySchedulerAsync(CreateWeeklySchedulerDto request);
    public Task<ResponseDto<NoContentDto>> UpdateWeeklySchedulerAsync(UpdateWeeklySchedulerDto request);
    public Task<ResponseDto<IList<WeeklySchedulerResponseDto>>> GetWeeklySchedulersAsync(Guid habitId);
    public Task<ResponseDto<NoContentDto>> ClearWeeklySchedulersAsync(Guid habitId);
}
