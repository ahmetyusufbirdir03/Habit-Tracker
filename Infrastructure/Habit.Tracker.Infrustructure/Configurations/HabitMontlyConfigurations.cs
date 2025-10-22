using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrastructure.Configurations;

public class HabitMonthlyConfiggurations : IEntityTypeConfiguration<HabitMonthly>
{
    public void Configure(EntityTypeBuilder<HabitMonthly> builder)
    {
        builder.ToTable("habit_monthly");
        builder.HasKey(m => m.Id);

        builder.Property(m => m.DayOfMonth).IsRequired();
        builder.Property(m => m.ReminderTime).IsRequired()
            .HasColumnType("time");

        builder.HasOne(m => m.Habit)
               .WithMany(h => h.MonthlySchedules)
               .HasForeignKey(m => m.HabitId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}


