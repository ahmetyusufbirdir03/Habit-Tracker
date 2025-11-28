class WeeklySchedulerDto {
  String? id;
  String? habitId;
  String? reminderTime;
  int? dayOfWeek;
  bool? isDone;

  WeeklySchedulerDto({this.id, this.habitId, this.reminderTime, this.dayOfWeek, this.isDone});

  WeeklySchedulerDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    habitId = json['habitId'];
    reminderTime = json['reminderTime'];
    dayOfWeek = json['dayOfWeek'];
    isDone = json['isDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['habitId'] = habitId;
    data['reminderTime'] = reminderTime;
    data['dayOfWeek'] = dayOfWeek;
    data['isDone'] = isDone;
    return data;
  }
}