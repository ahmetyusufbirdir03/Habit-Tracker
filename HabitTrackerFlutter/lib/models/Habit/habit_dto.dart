import '../../base/period_type_enum.dart';

class HabitListDto {
  final List<HabitDto> habitList;
  HabitListDto(this.habitList);

  factory HabitListDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonList = json['data'] as List<dynamic>? ?? [];
    final habits = jsonList
        .map((e) => HabitDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return HabitListDto(habits);
  }
}

class HabitDto {
  String? id;
  String? name;
  String? startDate;
  int? streak;
  int? bestStreak;
  PeriodType?  periodType;
  int? frequency;
  bool? isActive;
  String? notes;
  bool? isDone;
  DateTime? createdDate;

  HabitDto({
    this.id,
    this.name,
    this.startDate,
    this.streak,
    this.bestStreak,
    this.periodType,
    this.frequency,
    this.isActive,
    this.notes,
    this.isDone,
    this.createdDate,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      startDate: json['startDate'] as String?,
      streak: json['streak'] as int?,
      bestStreak: json['bestStreak'] as int?,
      periodType: json['periodType'] != null
          ? PeriodTypeExtension.fromInt(json['periodType'])
          : null,
      frequency: json['frequency'] as int?,
      isActive: json['isActive'] as bool?,
      isDone: json['isDone'] as bool?,
      notes: json['notes'] as String?,
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate,
      'streak': streak,
      'bestStreak': bestStreak,
      'isDone': isDone,
      'periodType': periodType,
      'frequency': frequency,
      'isActive': isActive,
      'notes': notes,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}
