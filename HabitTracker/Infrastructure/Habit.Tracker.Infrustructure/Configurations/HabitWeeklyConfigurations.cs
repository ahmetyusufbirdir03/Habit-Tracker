using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrastructure.Configurations;

public class HabitWeeklyConfig : IEntityTypeConfiguration<HabitWeekly>
{
    public void Configure(EntityTypeBuilder<HabitWeekly> builder)
    {
        builder.ToTable("habit_weekly_schedules");

        builder.HasKey(hw => hw.Id);

        builder.Property(hw => hw.Id)
               .ValueGeneratedOnAdd();

        builder.Property(hw => hw.HabitId)
               .IsRequired();

        builder.Property(hw => hw.DayOfWeek)
               .IsRequired()
               .HasMaxLength(20);

        builder.Property(hd => hd.IsDone)
            .IsRequired();

        builder.Property(hw => hw.ReminderTime)
               .IsRequired()
               .HasColumnType("time");

        // Relationships
        builder.HasOne(hw => hw.Habit)
               .WithMany(h => h.WeeklySchedules)
               .HasForeignKey(hw => hw.HabitId)
               .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(hw => hw.HabitId);

        builder.HasIndex(hw => new { hw.HabitId, hw.DayOfWeek, hw.ReminderTime })
       .IsUnique();

    }
}