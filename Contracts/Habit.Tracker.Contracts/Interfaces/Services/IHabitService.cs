using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.Habit;
using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.Habit.Update;
using Habit.Tracker.Contracts.Dtos.Habit.Update.Note;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IHabitService
{
    public Task<ResponseDto<NoContentDto>> CreateHabit(CreateHabitRequestDto request);
    public Task<ResponseDto<NoContentDto>> DeleteHabit(Guid id);
    public Task<ResponseDto<NoContentDto>> UpdateHabitAsync(UpdateHabitRequestDto request);
    public Task<ResponseDto<IList<HabitDetailDto>>> GetUserHabitsAsync(Guid userId);
    public Task<ResponseDto<IList<HabitDetailDto>>> GetAllHabits();
}
