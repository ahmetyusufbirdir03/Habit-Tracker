using Habit.Tracker.Application.Services;
using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Create;
using Habit.Tracker.Contracts.Dtos.SpecialReminder.Update;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers;

public class SpecialReminderController : BaseController
{
    private readonly ISpecialReminderService _specialReminderService;

    public SpecialReminderController(ISpecialReminderService specialReminderService)
    {
        _specialReminderService = specialReminderService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateReminder(CreateSpecialReminderRequestDto request)
    {
        var response = await _specialReminderService.CreateSpecialReminderAsync(request);

        return StatusCode(response.StatusCode, response);
    }

    [HttpDelete("{reminderId}")]
    public async Task<IActionResult> DeleteReminder(Guid reminderId)
    {
        var response = await _specialReminderService.DeleteSpecialReminderAsync(reminderId);

        return StatusCode(response.StatusCode, response);
    }

    [HttpGet("{groupId}")]
    public async Task<IActionResult> GetGroupSpecialReminders(Guid groupId)
    {
        var response = await _specialReminderService.GetSpecialReminderAsync(groupId);

        return StatusCode(response.StatusCode, response);
    }

    [HttpPatch]
    public async Task<IActionResult> UpdateSpecialReminder(UpdateSpecialReminderRequestDto request)
    {
        var response = await _specialReminderService.UpdateSpecialReminderAsync(request);

        return StatusCode(response.StatusCode, response);
    }
}
