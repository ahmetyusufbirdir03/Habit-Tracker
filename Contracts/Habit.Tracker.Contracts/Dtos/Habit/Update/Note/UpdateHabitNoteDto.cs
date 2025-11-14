namespace Habit.Tracker.Contracts.Dtos.Habit.Update.Note;

public class UpdateHabitNoteDto
{
    public Guid HabitId { get; set; }
    public string? Note { get; set; }
}
