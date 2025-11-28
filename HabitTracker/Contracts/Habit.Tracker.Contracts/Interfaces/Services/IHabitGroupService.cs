using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.HabitGroup;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Create;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface IHabitGroupService
{
    public Task<ResponseDto<NoContentDto>> CreateHabitGroup(HabitGroupCreateRequestDto request);
    public Task<ResponseDto<IList<HabitGroupResponseDto>>> GetAllHabitGroups();
    public Task<ResponseDto<IList<HabitGroupResponseDto>>> GetAllHabitGroupsByUserId(Guid id);
    public Task<ResponseDto<NoContentDto>> DeleteHabitGroup(Guid id);
    public Task<ResponseDto<NoContentDto>> UpdateHabitGroup(UpdateHabitGroupRequestDto request);
}
