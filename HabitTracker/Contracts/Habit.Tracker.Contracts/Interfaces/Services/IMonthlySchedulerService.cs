using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IMonthlySchedulerService
{
    public Task<ResponseDto<NoContentDto>> CreateMonthlySchedulerAsync(CreateMonthlySchedulerDto request);

    public Task<ResponseDto<NoContentDto>> ClearMonthlySchedulerAsync(Guid habitId);

    public Task<ResponseDto<IList<MonthlySchedulerResponseDto>>> GetMonthlySchedulersAsync(Guid habitId);

    public Task<ResponseDto<NoContentDto>> UpdateMonthlySchedulerAsync(UpdateMonthlySchedulerDto request);

    public Task<ResponseDto<NoContentDto>> CompleteMonthlySchedulerAsync(Guid schedulerId);
}
