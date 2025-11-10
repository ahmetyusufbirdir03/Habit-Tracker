using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrastructure.Configurations;

public class HabitConfig : IEntityTypeConfiguration<HabitEntity>
{
    public void Configure(EntityTypeBuilder<HabitEntity> builder)
    {
        builder.ToTable("habits");

        builder.HasKey(h => h.Id);

        builder.Property(h => h.Name)
               .IsRequired()
               .HasMaxLength(100);

        builder.Property(h => h.StartDate)
               .IsRequired();

        builder.Property(h => h.Streak)
               .IsRequired()
               .HasDefaultValue(0);

        builder.Property(h => h.PeriodType)
               .IsRequired();

        builder.Property(h => h.Frequency)
               .IsRequired();

        builder.Property(h => h.IsActive)
               .IsRequired()
               .HasDefaultValue(false);

        builder.Property(h => h.Notes)
               .HasMaxLength(1000)
               .IsRequired(false);

        builder.Property(h => h.HabitGroupId)
               .IsRequired();

        // Relations
        builder.HasOne(h => h.HabitGroup)
               .WithMany(hg => hg.Habits)
               .HasForeignKey(h => h.HabitGroupId)
               .OnDelete(DeleteBehavior.Cascade);

        // Daily schedules
        builder.HasMany(h => h.DailySchedules)
               .WithOne(d => d.Habit)
               .HasForeignKey(d => d.HabitId)
               .OnDelete(DeleteBehavior.Cascade);

        // Weekly schedules
        builder.HasMany(h => h.WeeklySchedules)
               .WithOne(w => w.Habit)
               .HasForeignKey(w => w.HabitId)
               .OnDelete(DeleteBehavior.Cascade);

        // Monthly schedules
        builder.HasMany(h => h.MonthlySchedules)
               .WithOne(m => m.Habit)
               .HasForeignKey(m => m.HabitId)
               .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(h => h.HabitGroupId);
        builder.HasIndex(h => h.PeriodType);
        builder.HasIndex(h => h.IsActive);
        builder.HasIndex(h => h.StartDate);
    }
}