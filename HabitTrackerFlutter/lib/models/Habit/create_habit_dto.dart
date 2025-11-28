class CreateHabitDto {
  final String? name;
  final int? periodType;
  final int? frequency;
  final String? habitGroupId;
  final String? notes;

  CreateHabitDto({
    required this.name,
    required this.periodType,
    required this.frequency,
    required this.habitGroupId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'periodType': periodType,
      'frequency': frequency,
      'habitGroupId': habitGroupId,
      'notes': notes,
    };
  }
}
