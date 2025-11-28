class MonthlySchedulerRequestDto {
  int? dayOfMonth;
  String? reminderTime;

  MonthlySchedulerRequestDto({this.dayOfMonth, this.reminderTime});

  MonthlySchedulerRequestDto.fromJson(Map<String, dynamic> json) {
    dayOfMonth = json['dayOfMonth'];
    reminderTime = json['reminderTime'];
  }

  Map<String, dynamic> toJson() {
    return {
      "dayOfMonth": dayOfMonth,
      "reminderTime": reminderTime
    };
  }
}