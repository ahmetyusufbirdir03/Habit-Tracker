using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrastructure.Configurations;

public class HabitDailyConfig : IEntityTypeConfiguration<HabitDaily>
{
    public void Configure(EntityTypeBuilder<HabitDaily> builder)
    {
        builder.ToTable("habit_daily_schedules");

        builder.HasKey(hd => hd.Id);

        builder.Property(hd => hd.Id)
               .ValueGeneratedOnAdd();

        builder.Property(hd => hd.HabitId)
               .IsRequired();

        builder.Property(hd => hd.isDoneToday)
            .IsRequired();


        builder.Property(hd => hd.ReminderTime)
               .IsRequired()
               .HasColumnType("time");

        // Relationships
        builder.HasOne(hd => hd.Habit)
               .WithMany(h => h.DailySchedules)
               .HasForeignKey(hd => hd.HabitId)
               .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(hd => hd.HabitId);
    }
}