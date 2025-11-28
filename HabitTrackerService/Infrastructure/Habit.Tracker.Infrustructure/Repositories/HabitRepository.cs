using Habit.Tracker.Contracts.Interfaces.Repositories;
using Habit.Tracker.Domain.Entities;
using Habit.Tracker.Infrustructure.Context;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace Habit.Tracker.Infrastructure.Repositories
{
    public class HabitRepository : IHabitRepository
    {
        private readonly AppDbContext _dbContext;
        public HabitRepository(AppDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<List<HabitEntity>> GetHabitsWithSchedulersAsync()
        {
            var habits = await _dbContext.Habits
            .Include(h => h.HabitGroup)
            .Include(h => h.DailySchedules)
            .Include(h => h.WeeklySchedules)
            .Include(h => h.MonthlySchedules)
            .ToListAsync();

            return habits;
        }

        public async Task<List<HabitEntity>> GetUserHabitsAsync(Guid userId)
        {
            var habits = await _dbContext.Habits
            .Include(h => h.HabitGroup)
            .Include(h => h.DailySchedules)
            .Include(h => h.WeeklySchedules)
            .Include(h => h.MonthlySchedules)
            .Where(h => h.HabitGroup.UserId == userId)
            .ToListAsync();

            return habits;
        }
    }
}
