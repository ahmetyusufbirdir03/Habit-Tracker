﻿using System.Linq.Expressions;

namespace Habit.Tracker.Contracts.Interfaces.Repositories;

public interface IGenericRepository<T> where T : class
{
    Task<T> CreateAsync(T entity);
    Task DeleteAsync(T entity);
    Task SoftDeleteAsync(T entity);
    Task<T> UpdateAsync(T entity);
    Task<List<T>> GetAllAsync(Expression<Func<T, bool>>? predicate = null);
    Task<T?> GetByIdAsync(Guid Id, params Expression<Func<T, object>>[] includes);
    Task<bool> AnyAsync(Expression<Func<T, bool>> predicate);
    Task RemoveRangeAsync(IEnumerable<T> entities);

}
