using Habit.Tracker.Contracts.Dtos.Habit.Create;
using Habit.Tracker.Contracts.Dtos.Habit.Update;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers
{
    public class HabitController : BaseController
    {
        private readonly IHabitService _habitService;

        public HabitController(IHabitService habitService)
        {
            _habitService = habitService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateHabit(CreateHabitRequestDto request)
        {
            var response = await _habitService.CreateHabit(request);

            return StatusCode(response.StatusCode, response);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteHabit(Guid id)
        {
            var response = await _habitService.DeleteHabit(id);

            return StatusCode(response.StatusCode, response);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserHabits(Guid id)
        {
            var response = await _habitService.GetUserHabitsAsync(id);

            return StatusCode(response.StatusCode, response);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllHabits()
        {
            var response = await _habitService.GetAllHabits();

            return StatusCode(response.StatusCode, response);
        }

        [HttpPatch]
        public async Task<IActionResult> UpdateHabit(UpdateHabitRequestDto request)
        {
            var response = await _habitService.UpdateHabitAsync(request);

            return StatusCode(response.StatusCode, response);
        }
    }
}
