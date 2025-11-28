using Microsoft.AspNetCore.Mvc;

namespace Habit.Tracker.Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public abstract class BaseController : ControllerBase
    {
    }
}
