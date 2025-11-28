class CreateHabitGroupDto {
  String? userId;
  String? name;
  CreateHabitGroupDto({this.userId, this.name});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'UserId': userId,
      'Name': name,
    };
    return data;
  }
}