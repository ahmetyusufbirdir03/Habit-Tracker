using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.DailySchedule;
using Habit.Tracker.Contracts.Dtos.DailySchedule.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IDailyScheduleService
{
    public Task<ResponseDto<NoContentDto>> CreateDailyScheduleAsync(CreateDailyScheduleRequestDto request);
    public Task<ResponseDto<NoContentDto>> UpdateDailyScheduleAsync(UpdateDailySchedulerRequestDto request);
    public Task<ResponseDto<IList<DailyHabitResponseDto>>> GetHabitSchedulesAsync(Guid habitId);
}

