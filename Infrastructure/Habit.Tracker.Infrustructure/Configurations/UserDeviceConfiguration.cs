using Habit.Tracker.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Habit.Tracker.Infrastructure.Configurations
{
    public class UserDeviceConfiguration : IEntityTypeConfiguration<UserDevice>
    {
        public void Configure(EntityTypeBuilder<UserDevice> builder)
        {
            builder.ToTable("UserDevices");

            builder.Property(ud => ud.FcmToken)
                   .HasMaxLength(500)
                   .IsRequired();

            builder.Property(ud => ud.Platform)
                   .HasMaxLength(50)
                   .IsRequired(false);

            builder.Property(ud => ud.LastActiveDate)
                   .IsRequired();

            builder.HasOne(ud => ud.User)
                   .WithMany()
                   .HasForeignKey(ud => ud.UserId)
                   .OnDelete(DeleteBehavior.Cascade);

            builder.HasIndex(ud => ud.UserId);
            builder.HasIndex(ud => ud.FcmToken).IsUnique();
        }
    }
}
