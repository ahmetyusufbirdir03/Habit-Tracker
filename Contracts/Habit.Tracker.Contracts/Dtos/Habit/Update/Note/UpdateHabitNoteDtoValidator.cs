using FluentValidation;

namespace Habit.Tracker.Contracts.Dtos.Habit.Update.Note;

public class UpdateHabitNoteDtoValidator : AbstractValidator<UpdateHabitNoteDto>
{
    public UpdateHabitNoteDtoValidator()
    {
        RuleFor(x => x.Note)
            .MaximumLength(100).WithMessage("Notlar en fazla 100 karakter olabilir")
            .When(x => !string.IsNullOrWhiteSpace(x.Note));
    }
}
