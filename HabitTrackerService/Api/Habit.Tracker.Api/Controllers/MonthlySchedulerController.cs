using Habit.Tracker.Application.Services.SchedulerServices;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Create;
using Habit.Tracker.Contracts.Dtos.MonthlyScheduler.Update;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers
{
    public class MonthlySchedulerController : BaseController
    {
        private readonly IMonthlySchedulerService _monthlySchedulerService;

        public MonthlySchedulerController(IMonthlySchedulerService monthlySchedulerService)
        {
            _monthlySchedulerService = monthlySchedulerService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateMonthlySchedule(CreateMonthlySchedulerDto request)
        {
            var response = await _monthlySchedulerService.CreateMonthlySchedulerAsync(request);

            return StatusCode(response.StatusCode, response);
        }

        [HttpDelete("habitId")]
        public async Task<IActionResult> ClearMonthlySchedule(Guid habitId)
        {
            var response = await _monthlySchedulerService.ClearMonthlySchedulerAsync(habitId);

            return StatusCode(response.StatusCode, response);
        }

        [HttpGet("{habitId}")]
        public async Task<IActionResult> GetMonthlySchedulers(Guid habitId)
        {
            var response = await _monthlySchedulerService.GetMonthlySchedulersAsync(habitId);

            return StatusCode(response.StatusCode, response);
        }

        [HttpPatch]
        public async Task<IActionResult> UpdateMonthlySchedulers(UpdateMonthlySchedulerDto request)
        {
            var response = await _monthlySchedulerService.UpdateMonthlySchedulerAsync(request);

            return StatusCode(response.StatusCode, response);
        }

        [HttpPatch("{SchedulerId}")]
        public async Task<IActionResult> CompleteMonthlyScheduler(Guid SchedulerId)
        {
            var response = await _monthlySchedulerService.CompleteMonthlySchedulerAsync(SchedulerId);

            return StatusCode(response.StatusCode, response);
        }
    }
}
