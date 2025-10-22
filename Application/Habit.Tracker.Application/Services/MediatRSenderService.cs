using FluentValidation;
using FluentValidation.Results;
using Habit.Tracker.Contracts.Interfaces.CustomMediatR;
using Microsoft.Extensions.DependencyInjection;

namespace Habit.Tracker.Application.Services;

public class MediatRSenderService(IServiceProvider provider) : ISender
{
    private readonly IServiceProvider _provider = provider;

    public Task<TResponse> Send<TResponse>(IRequest<TResponse> request, CancellationToken cancellationToken = default)
    {

        var validatorType = typeof(IValidator<>).MakeGenericType(request.GetType());
        var validators = (IEnumerable<object>?)_provider.GetServices(validatorType) ?? Enumerable.Empty<object>();

        foreach (var v in validators)
        {
            dynamic validator = v;
            ValidationResult result = validator.Validate((dynamic)request);
            if (!result.IsValid)
                throw new ValidationException(result.Errors);
        }

        var handlerType = typeof(IRequestHandler<,>).MakeGenericType(request.GetType(), typeof(TResponse));
        dynamic? handler = _provider.GetService(handlerType);

        if (handler == null)
            throw new Exception("NullHandlerException");

        return handler.Handle((dynamic)request, cancellationToken);
    }
}
