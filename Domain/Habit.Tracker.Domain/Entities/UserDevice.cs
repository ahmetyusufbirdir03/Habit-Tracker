namespace Habit.Tracker.Domain.Entities
{
    public class UserDevice : BaseEntity
    {
        public Guid UserId { get; set; }
        public User? User { get; set; }
        public string FcmToken { get; set; } = string.Empty;
        public string? Platform { get; set; }
        public DateTime LastActiveDate { get; set; } = DateTime.UtcNow;
    }
}
