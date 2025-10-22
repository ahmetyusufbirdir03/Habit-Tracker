namespace Habit.Tracker.Contracts.Interfaces.CustomMediatR;

public interface ISender
{
    Task<TResponse> Send<TResponse>(
        IRequest<TResponse> request,
        CancellationToken cancellationToken = default);
}