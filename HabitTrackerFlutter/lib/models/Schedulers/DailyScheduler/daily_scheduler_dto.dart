class DailySchedulerDto {
  String? id;
  String? habitId;
  String? reminderTime;
  bool? isDone;

  DailySchedulerDto({this.id, this.habitId, this.reminderTime, this.isDone});

  DailySchedulerDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    habitId = json['habitId'];
    reminderTime = json['reminderTime'];
    isDone = json['isDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['habitId'] = habitId;
    data['reminderTime'] = reminderTime;
    data['isDone'] = isDone;
    return data;
  }
}