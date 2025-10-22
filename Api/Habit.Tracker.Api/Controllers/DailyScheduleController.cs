using Habit.Tracker.Contracts.Dtos.DailyHabit.Create;
using Habit.Tracker.Contracts.Dtos.DailySchedule.Update;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers
{
    public class DailyScheduleController : BaseController
    {
        private readonly IDailyScheduleService _dailyScheduleService;

        public DailyScheduleController(IDailyScheduleService dailyScheduleService)
        {
            _dailyScheduleService = dailyScheduleService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateDailySchedule(CreateDailyScheduleRequestDto request)
        {
            var response = await _dailyScheduleService.CreateDailyScheduleAsync(request);

            return StatusCode(response.StatusCode, response);
        }

        [HttpGet("{habitId}")]
        public async Task<IActionResult> GetHabitDailySchedules(Guid habitId)
        {
            var response = await _dailyScheduleService.GetHabitSchedulesAsync(habitId);

            return StatusCode(response.StatusCode, response);
        }

        [HttpDelete("habiId")]
        public async Task<IActionResult> ClearDailySchedule(Guid habitId)
        {
            var response = await _dailyScheduleService.ClearHabitSchedulesAsync(habitId);

            return StatusCode(response.StatusCode, response);
        }

        [HttpPatch]
        public async Task<IActionResult> UpdateDailySchedule(UpdateDailySchedulerRequestDto request)
        {
            var response = await _dailyScheduleService.UpdateDailyScheduleAsync(request);

            return StatusCode(response.StatusCode, response);
        }
    }
}
