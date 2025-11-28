import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/Habit/habit_dto.dart';
import 'package:habit_tracker_mobile/models/Schedulers/MonthlyScheduler/monthly_scheduler_request_dto.dart';
import 'package:habit_tracker_mobile/services/auth_service.dart';

import '../../../services/scheduler_service.dart';
import '../../PopUp/error_response_popup.dart';


class SimpleMonthlyPicker extends StatefulWidget {
  final HabitDto habit;
  final Color backgroundColor;

  const SimpleMonthlyPicker({
    Key? key,
    required this.habit,
    this.backgroundColor = const Color(0xFFA7AAE1),
  }) : super(key: key);

  @override
  _SimpleMonthlyPickerState createState() => _SimpleMonthlyPickerState();
}

class _SimpleMonthlyPickerState extends State<SimpleMonthlyPicker> {
  final _schedulerService = SchedulerService();
  final _authService = AuthService();

  final List<MonthlySchedulerRequestDto> _schedules = [];

  int? _selectedDayOfMonth = 1;
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 12, minute: 0);

  void _addSchedule() {
    if (_schedules.length >= widget.habit.frequency!) {
      return;
    }

    if (_selectedDayOfMonth == null || _selectedTime == null) {
      return;
    }

    final String timeString =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

    final newSchedule = MonthlySchedulerRequestDto(
      dayOfMonth: _selectedDayOfMonth!,
      reminderTime: timeString,
    );

    setState(() {
      _schedules.add(newSchedule);
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<bool> _createSchedulers(String habitId, List<MonthlySchedulerRequestDto> timerList) async {
    final isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      await AuthService.logout(context);
      return false;
    }

    final response = await _schedulerService.createMonthlySchedulersAsync(habitId, timerList);

    if (!response.isSuccess && response.statusCode != 201) {
      showErrorDialog(
        context: context,
        title: response.message ?? "Error",
        errors: response.errors ?? ["Unknown error"],
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isLimitReached = _schedules.length >= widget.habit.frequency!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // TOP BAR
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          Text(
            '${_schedules.length} / ${widget.habit.frequency!} zamanlayıcı eklendi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLimitReached ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          // GÜN ve SAAT SEÇİMİ
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedDayOfMonth,
                  items: List.generate(31, (i) {
                    final day = i + 1;
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text(
                        '$day. Gün',
                        style: TextStyle(color: isLimitReached ? Colors.red : Colors.black),
                      ),
                    );
                  }),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isLimitReached ? Colors.red : Colors.black,
                  ),
                  onChanged: isLimitReached
                      ? null
                      : (value) {
                    setState(() {
                      _selectedDayOfMonth = value;
                    });
                  },
                  underline: const SizedBox(),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: isLimitReached ? null : _pickTime,
                child: Text(
                  _selectedTime == null ? 'Saat Seç' : _selectedTime!.format(context),
                  style: TextStyle(color: isLimitReached ? Colors.red : Colors.black),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: isLimitReached ? Colors.red : Colors.black),
                onPressed: isLimitReached ? null : _addSchedule,
              ),
            ],
          ),

          const Divider(color: Colors.black),

          // SEÇİLENLERİN LİSTESİ
          Expanded(
            child: ListView.separated(
              itemCount: _schedules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                final time = schedule.reminderTime!.substring(0, 5);

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                        'Day ${schedule.dayOfMonth} of the month - $time',
                        style: const TextStyle(color: Colors.black),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _schedules.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // KAYDET BUTONU
          ElevatedButton(
            child: const Text('Kaydet'),
            onPressed: () async {
              bool isOk = await _createSchedulers(widget.habit.id!, _schedules);
              if (isOk) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
    );
  }
}
