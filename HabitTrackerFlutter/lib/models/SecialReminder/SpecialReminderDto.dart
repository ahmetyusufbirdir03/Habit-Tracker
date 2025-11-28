class SpecialReminderDto {
  String? id;
  String? title;
  String? description;
  int? day;
  int? month;

  SpecialReminderDto({this.id, this.title, this.description, this.day, this.month});

  SpecialReminderDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    day = json['day'];
    month = json['month'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['day'] = day;
    data['month'] = month;
    return data;
  }
}