using Habit.Tracker.Application.Services;
using Habit.Tracker.Contracts.Dtos.DailySchedule.Update;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.WeeklyScheduler.Update;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers;

public class WeeklySchedulerController : BaseController
{
    private readonly IWeeklySchedulerService _weeklySchedulerService;

    public WeeklySchedulerController(IWeeklySchedulerService weeklyScheduler)
    {
        _weeklySchedulerService = weeklyScheduler;
    }

    [HttpPost]
    public async Task<IActionResult> CreateWeeklySchedule(CreateWeeklySchedulerDto request)
    {
        var response = await _weeklySchedulerService.CreateWeeklySchedulerAsync(request);

        return StatusCode(response.StatusCode, response);
    }

    [HttpDelete("habitId")]
    public async Task<IActionResult> ClearWeeklySchedule(Guid habitId)
    {
        var response = await _weeklySchedulerService.ClearWeeklySchedulersAsync(habitId);

        return StatusCode(response.StatusCode, response);
    }

    [HttpGet("{habitId}")]
    public async Task<IActionResult> GetHabitWeeklySchedules(Guid habitId)
    {
        var response = await _weeklySchedulerService.GetWeeklySchedulersAsync(habitId);

        return StatusCode(response.StatusCode, response);
    }

    [HttpPatch]
    public async Task<IActionResult> UpdateWeeklyScheduler(UpdateWeeklySchedulerDto request)
    {
        var response = await _weeklySchedulerService.UpdateWeeklySchedulerAsync(request);

        return StatusCode(response.StatusCode, response);
    }
}
