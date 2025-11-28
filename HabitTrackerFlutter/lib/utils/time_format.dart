import 'package:intl/intl.dart';

String formatTime(String time) {
  try {
    final dt = DateTime.parse("2000-01-01 $time");
    return DateFormat.Hm().format(dt);
  } catch (e) {
    return time;
  }
}

String formatDate(String dateString) {
  try {
    final dt = DateTime.parse(dateString);
    return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}";
  } catch (e) {
    return dateString;
  }
}



class DateResult {
  final DateTime? date;
  final String? error;

  DateResult({this.date, this.error});
  @override
  String toString() {
    if (error != null) return error!;
    if (date != null) return "${date!.day}/${date!.month}/${date!.year}";
    return "";
  }
}

bool _isLeapYear(int year) {
  return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
}

DateResult formatDayMonth({required int day, int? month}) {
  final now = DateTime.now();

  try {
    if (month == null) {
      var dt = DateTime(now.year, now.month, day);
      if (dt.isBefore(now)) {
        dt = DateTime(now.year, now.month + 1, day);
      }
      return DateResult(date: dt);
    } else {
      var dt = DateTime(now.year, month, day);

      if (dt.month != month && day == 29 && month == 2) {
        int nextLeapYear = now.year;
        while (true) {
          nextLeapYear++;
          if (_isLeapYear(nextLeapYear)) {
            return DateResult(error:
            "You have selected a leap year date.\nThe next available leap-year date is 29/02/$nextLeapYear."
            );
          }
        }
      }

      if (DateTime(now.year, now.month, now.day)
          .isAfter(DateTime(now.year, month, day))) {
        dt = DateTime(now.year + 1, month, day);

        if (dt.month != month && day == 29 && month == 2) {
          int nextLeapYear = now.year + 1;
          while (true) {
            nextLeapYear++;
            if (_isLeapYear(nextLeapYear)) {
              return DateResult(error:
              "Next year is not a leap year. The next available leap-year date is 29/02/$nextLeapYear."
              );
            }
          }
        }
      }
      return DateResult(date: dt);
    }

  } catch (_) {
    return DateResult(error: "Geçersiz tarih");
  }
}
