import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/screens/weekly_scheduler_screen.dart';
import '../models/Habit/habit_dto.dart';
import '../models/HabitGroup/habit_group_dto.dart';
import '../base/period_type_enum.dart';
import 'daily_scheduler_screen.dart';
import 'monthly_scheduler_screen.dart';

class HabitScreen extends StatelessWidget {
  final HabitDto habit;
  final HabitGroupDto habitGroup;

  const HabitScreen({super.key, required this.habit, required this.habitGroup});

  Widget getSchedulerWidget() {
    if (habit.periodType == PeriodType.daily) {
      return DailySchedulerScreen(habit: habit, habitGroup: habitGroup);
    } else if (habit.periodType == PeriodType.weekly) {
      return WeeklySchedulerScreen(habit: habit, habitGroup: habitGroup);
    }else if (habit.periodType == PeriodType.monthly) {
      return MonthlySchedulerScreen(habit: habit, habitGroup: habitGroup);
    } else {
      return DailySchedulerScreen(habit: habit, habitGroup: habitGroup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getSchedulerWidget(),
    );
  }
}
