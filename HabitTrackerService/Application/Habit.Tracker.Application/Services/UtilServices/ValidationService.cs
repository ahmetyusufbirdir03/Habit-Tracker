using FluentValidation;
using Habit.Tracker.Contracts.Dtos;
using Habit.Tracker.Contracts.Interfaces.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

namespace Habit.Tracker.Application.Services.UtilServices
{
    public class ValidationService : IValidationService
    {
        private readonly IServiceProvider _serviceProvider;

        public ValidationService(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        public async Task<ResponseDto<TResponse>?> ValidateAsync<TRequest, TResponse>(TRequest request)
        where TResponse : class
        {
            var validator = _serviceProvider.GetService<IValidator<TRequest>>();

            if (validator == null)
                return ResponseDto<TResponse>.Fail("no validator",StatusCodes.Status404NotFound); 

            var validationResult = await validator.ValidateAsync(request);

            if (!validationResult.IsValid)
            {
                var errors = validationResult.Errors
                    .Select(e => e.ErrorMessage)
                    .ToList();
                return ResponseDto<TResponse>.Fail(errors, StatusCodes.Status400BadRequest);
            }

            return null; 
        }
    }
}
