using Habit.Tracker.Domain.Entities;

namespace Habit.Tracker.Contracts.Interfaces.Repositories;

public interface IHabitRepository
{
    Task<List<HabitEntity>> GetUserHabitsAsync(Guid userId);
}

