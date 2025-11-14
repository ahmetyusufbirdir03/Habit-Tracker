using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrustructure.Configurations;

public class HabitGroupConfig : IEntityTypeConfiguration<HabitGroup>
{
    public void Configure(EntityTypeBuilder<HabitGroup> builder)
    {
        builder.ToTable("habit_groups");
        builder.HasKey(h => h.Id);

        builder.Property(h => h.Name)
               .IsRequired()
               .HasMaxLength(100);

        builder.HasMany(h => h.Habits)
               .WithOne(habit => habit.HabitGroup)
               .HasForeignKey(habit => habit.HabitGroupId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(h => h.SpecialReminders)
               .WithOne(reminder => reminder.HabitGroup)
               .HasForeignKey(reminder => reminder.HabitGroupId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
