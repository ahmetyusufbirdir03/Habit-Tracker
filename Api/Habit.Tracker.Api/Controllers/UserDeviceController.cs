using Habit.Tracker.Contracts.Dtos.User.Device;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers;

public class UserDeviceController : BaseController
{
    private readonly IUserDeviceService _userDeviceService;

    public UserDeviceController(IUserDeviceService userDeviceService)
	{
        _userDeviceService = userDeviceService;
    }

    [HttpPost]
    public async Task<IActionResult> SaveDevice(SaveDeviceTokenRequestDto request)
    {
        var response = await _userDeviceService.SaveDeviceTokenAsync(request);

        return StatusCode(response.StatusCode, response);
    }
}
