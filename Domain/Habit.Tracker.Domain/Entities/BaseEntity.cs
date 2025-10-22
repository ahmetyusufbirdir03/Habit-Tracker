﻿namespace Habit.Tracker.Domain.Entities;
public class BaseEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedDate { get; set; }
    public string? CreatedBy { get; set; }
    public DateTime UpdatedDate { get; set; }
    public string? UpdatedBy { get; set; }
    public DateTime DeletedDate { get; set; }
    public string? DeletedBy { get; set; }
}
