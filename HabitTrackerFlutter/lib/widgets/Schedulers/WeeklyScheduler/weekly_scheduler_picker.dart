import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/Habit/habit_dto.dart';
import 'package:habit_tracker_mobile/models/Schedulers/WeeklyScheduler/weekly_scheduler_request_dto.dart';
import 'package:habit_tracker_mobile/services/auth_service.dart';

import '../../../services/scheduler_service.dart';
import '../../PopUp/error_response_popup.dart';


class SimpleWeeklyPicker extends StatefulWidget {
  // GÜNCELLEME 1: Parametreleri ekleyin
  final HabitDto habit;
  final Color backgroundColor;

  const SimpleWeeklyPicker({
    Key? key,
    required this.habit,
    this.backgroundColor = const Color(0xFFA7AAE1),
  }) : super(key: key);

  @override
  _SimpleWeeklyPickerState createState() => _SimpleWeeklyPickerState();
}

class _SimpleWeeklyPickerState extends State<SimpleWeeklyPicker> {
  final Map<int, String> _daysOfWeek = {
    1: 'Pazartesi', 2: 'Salı', 3: 'Çarşamba', 4: 'Perşembe',
    5: 'Cuma', 6: 'Cumartesi', 7: 'Pazar',
  };

  final _schedulerService = SchedulerService();
  final _authService = AuthService();
  final List<WeeklySchedulerRequestDto> _schedules = [];

  int? _selectedDayKey = 1;
  TimeOfDay? _selectedTime = TimeOfDay(hour: 12, minute: 0);

  void _addSchedule() {
    if (_schedules.length >= widget.habit.frequency!) {
      return;
    }

    if (_selectedDayKey == null || _selectedTime == null) {
      return;
    }

    final String timeString =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

    final newSchedule = WeeklySchedulerRequestDto(
      dayOfWeek: _selectedDayKey!,
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

  Future<bool> createSchedulers(String habitId, List<WeeklySchedulerRequestDto> timerList) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      await AuthService.logout(context);
      return false;
    }
    final response = await _schedulerService.createWeeklySchedulersAsync(habitId,timerList);

    if (!response.isSuccess && response.statusCode != 201) {
      showErrorDialog(
          context: context,
          title: response.message ?? "Error",
          errors: response.errors ?? ["Unknown error"]
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
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
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

          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(

                  value: _selectedDayKey,
                  items: _daysOfWeek.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: TextStyle(color: isLimitReached ? Colors.red : Colors.black),
                      ),
                    );
                  }).toList(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color:  isLimitReached ? Colors.red : Colors.black,
                  ),
                  onChanged: isLimitReached ? null : (value) {
                    setState(() {
                      _selectedDayKey = value;
                    });
                  },
                  underline: const SizedBox(),
                )

              ),
              SizedBox(width: 10),

              TextButton(
                child: Text(_selectedTime == null ? 'Saat Seç' : _selectedTime!.format(context),
                  style:TextStyle(color:  isLimitReached ? Colors.red : Colors.black)),
                onPressed: isLimitReached ? null : _pickTime,
              ),

              IconButton(
                icon: Icon(Icons.add_circle, color:  isLimitReached ? Colors.red : Colors.black),
                onPressed: isLimitReached ? null : _addSchedule,
              ),
            ],
          ),
          Divider(color: Colors.black),

          Expanded(
            child: ListView.separated(
              itemCount: _schedules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                final dayName = _daysOfWeek[schedule.dayOfWeek] ?? 'Bilinmeyen Gün';
                final time = schedule.reminderTime.substring(0, 5);

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '$dayName - $time',
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
            )
          ),

          ElevatedButton(
            child: Text('Kaydet'),
            onPressed: () async {
              bool isOk = await createSchedulers(widget.habit.id!, _schedules);
              if(isOk){
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
    );
  }
}