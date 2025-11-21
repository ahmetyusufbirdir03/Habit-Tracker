using Habit.Tracker.Domain.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace Habit.Tracker.Infrustructure.Context;

public class AppDbContext : IdentityDbContext<User, Role, Guid>
{
    public AppDbContext(DbContextOptions options) : base(options)
    {
    }

    protected AppDbContext()
    {
    }

    public DbSet<HabitGroup> HabitGroup { get; set; }
    public DbSet<HabitEntity> Habits { get; set; }
    public DbSet<HabitDaily> HabitDaily { get; set; }
    public DbSet<HabitMonthly> HabitMonthly { get; set; }
    public DbSet<HabitWeekly> HabitWeekly { get; set; }
    public DbSet<UserDevice> UserDevices { get; set; }
    public DbSet<Notification> Notification { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

    
    }
}
