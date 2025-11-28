class MonthlySchedulerDto {
  String? id;
  String? habitId;
  int? dayOfMonth;
  String? reminderTime;
  bool? isDone;

  MonthlySchedulerDto({this.id, this.habitId, this.dayOfMonth, this.reminderTime, this.isDone});

  MonthlySchedulerDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    habitId = json['habitId'];
    dayOfMonth = json['dayOfMonth'];
    reminderTime = json['reminderTime'];
    isDone = json['isDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['habitId'] = this.habitId;
    data['dayOfMonth'] = this.dayOfMonth;
    data['reminderTime'] = this.reminderTime;
    data['isDone'] = this.isDone;
    return data;
  }
}