class DailySchedulerRequestDto {
  final String habitId;
  final List<String> reminderTimes;

  DailySchedulerRequestDto({required this.habitId, required this.reminderTimes});

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'reminderTimes': reminderTimes,
    };
  }
}
