class WeeklySchedulerRequestDto {
  final int dayOfWeek;
  final String reminderTime;

  WeeklySchedulerRequestDto({required this.dayOfWeek, required this.reminderTime});

  Map<String, dynamic> toJson() {
    return {
      "dayOfWeek": dayOfWeek,
      "reminderTime": reminderTime,
    };
  }
}