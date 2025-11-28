enum Month {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december,
}

extension MonthExtension on Month {
  String get displayName {
    switch (this) {
      case Month.january:
        return "January";
      case Month.february:
        return "February";
      case Month.march:
        return "March";
      case Month.april:
        return "April";
      case Month.may:
        return "May";
      case Month.june:
        return "June";
      case Month.july:
        return "July";
      case Month.august:
        return "August";
      case Month.september:
        return "September";
      case Month.october:
        return "October";
      case Month.november:
        return "November";
      case Month.december:
        return "December";
    }
  }

  // Backend'e gidecek int değeri
  int get value {
    switch (this) {
      case Month.january:
        return 1;
      case Month.february:
        return 2;
      case Month.march:
        return 3;
      case Month.april:
        return 4;
      case Month.may:
        return 5;
      case Month.june:
        return 6;
      case Month.july:
        return 7;
      case Month.august:
        return 8;
      case Month.september:
        return 9;
      case Month.october:
        return 10;
      case Month.november:
        return 11;
      case Month.december:
        return 12;
    }
  }

  // int → enum dönüşümü
  static Month fromInt(int value) {
    switch (value) {
      case 1:
        return Month.january;
      case 2:
        return Month.february;
      case 3:
        return Month.march;
      case 4:
        return Month.april;
      case 5:
        return Month.may;
      case 6:
        return Month.june;
      case 7:
        return Month.july;
      case 8:
        return Month.august;
      case 9:
        return Month.september;
      case 10:
        return Month.october;
      case 11:
        return Month.november;
      case 12:
        return Month.december;
      default:
        throw Exception("Invalid month value: $value");
    }
  }
}
