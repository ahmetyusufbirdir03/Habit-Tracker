using Habit.Tracker.Application.Services;
using Habit.Tracker.Contracts.Dtos.HabitGroup;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Create;
using Habit.Tracker.Contracts.Dtos.HabitGroup.Update;
using Habit.Tracker.Contracts.Dtos.User.Register;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers;

public class HabitGroupController : BaseController
{
    private readonly IHabitGroupService _habitGroupService;

    public HabitGroupController(IHabitGroupService habitGroupService)
    {
        _habitGroupService = habitGroupService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateHabitGroup(HabitGroupCreateRequestDto request)
    {
        var response = await _habitGroupService.CreateHabitGroup(request);

        return StatusCode(response.StatusCode, response);
    }

    [HttpGet]
    public async Task<ActionResult<IList<HabitGroupResponseDto>>> GetAllHabitGroups()
    {
        var response = await _habitGroupService.GetAllHabitGroups();

        return StatusCode(response.StatusCode, response);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<IList<HabitGroupResponseDto>>> GetAllHabitGroupsByUserId(Guid id)
    {
        var response = await _habitGroupService.GetAllHabitGroupsByUserId(id);

        return StatusCode(response.StatusCode, response);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteHabitGroup(Guid id)
    {
        var response = await _habitGroupService.DeleteHabitGroup(id);

        return StatusCode(response.StatusCode, response);
    }

    [HttpPatch]
    public async Task<IActionResult> UpdateHabitGroup(UpdateHabitGroupRequestDto request)
    {
        var response = await _habitGroupService.UpdateHabitGroup(request);

        return StatusCode(response.StatusCode, response);
    }

}
