using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Habit.Tracker.Domain.Entities;

public class SpecialReminderConfiguration : IEntityTypeConfiguration<SpecialReminder>
{
    public void Configure(EntityTypeBuilder<SpecialReminder> builder)
    {
        // Tablo adı
        builder.ToTable("SpecialReminders");

        // Primary key
        builder.HasKey(r => r.Id);

        // Alanlar
        builder.Property(r => r.Title)
            .HasMaxLength(250)
            .IsRequired(false);

        builder.Property(r => r.Description)
            .HasMaxLength(1000)
            .IsRequired(false);

        builder.Property(r => r.Month)
            .IsRequired();

        builder.Property(r => r.Day)
            .IsRequired();

        builder.Property(r => r.IsActive)
            .HasDefaultValue(true);

        // Relation: SpecialReminder -> HabitGroup (1-to-many)
        builder.HasOne(r => r.HabitGroup)
            .WithMany(hg => hg.SpecialReminders)
            .HasForeignKey(r => r.HabitGroupId)
            .OnDelete(DeleteBehavior.Cascade);

        // Index: Gruba göre sorgular hızlı olsun
        builder.HasIndex(r => r.HabitGroupId);

        // Optionally: Month + Day birleşik index, sık sorgularda faydalı
        builder.HasIndex(r => new { r.Month, r.Day });
    }
}
