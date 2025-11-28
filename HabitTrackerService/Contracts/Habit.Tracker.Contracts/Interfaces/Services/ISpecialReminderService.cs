using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Dtos.SpecialReminder;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;

namespace Habit.Tracker.Contracts.Interfaces.Services;

public interface ISpecialReminderService
{
    public Task<ResponseDto<NoContentDto>> CreateSpecialReminderAsync(CreateSpecialReminderRequestDto request);

    public Task<ResponseDto<NoContentDto>> DeleteSpecialReminderAsync(Guid reminderId);

    public Task<ResponseDto<IList<SpecialReminderResponseDto>>> 
        GetSpecialReminderAsync(Guid habitGroupId);

    public Task<ResponseDto<NoContentDto>> UpdateSpecialReminderAsync(UpdateSpecialReminderRequestDto request);
}
