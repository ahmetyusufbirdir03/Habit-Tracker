enum PeriodType {
  daily,
  weekly,
  monthly,
}

extension PeriodTypeExtension on PeriodType {
  String get displayName {
    switch (this) {
      case PeriodType.daily:
        return "Daily";
      case PeriodType.weekly:
        return "Weekly";
      case PeriodType.monthly:
        return "Monthly";
    }
  }

  int get value {
    switch (this) {
      case PeriodType.daily:
        return 1;
      case PeriodType.weekly:
        return 2;
      case PeriodType.monthly:
        return 3;
    }
  }

  static PeriodType fromInt(int value) {
    switch (value) {
      case 1:
        return PeriodType.daily;
      case 2:
        return PeriodType.weekly;
      case 3:
        return PeriodType.monthly;
      default:
        throw Exception("Geçersiz periyot tipi: $value");
    }
  }
}
