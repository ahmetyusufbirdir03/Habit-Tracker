using Habit.Tracker.Contracts.Interfaces.Repositories;

namespace Habit.Tracker.Contracts.Interfaces;

public interface IUnitOfWork : IAsyncDisposable
{
    IGenericRepository<T> GetGenericRepository<T>() where T : class, new();
    Task<int> SaveChangesAsync(); //asenkron
    int SaveChanges(); // senkron

}
