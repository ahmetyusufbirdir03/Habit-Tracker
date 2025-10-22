using Habit.Tracker.Contracts.Dtos;

namespace Habit.Tracker.Contracts.Interfaces.Services
{
    public interface IValidationService
    {
        Task<ResponseDto<TResponse>?> ValidateAsync<TRequest, TResponse>(TRequest request)
            where TResponse : class;
    }
}
