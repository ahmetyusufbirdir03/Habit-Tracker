import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/Schedulers/MonthlyScheduler/monthly_scheduler_dto.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/confirmation_popup.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/error_response_popup.dart';

class MonthlySchedulerEditPicker extends StatefulWidget {
  final MonthlySchedulerDto scheduler;

  const MonthlySchedulerEditPicker({super.key, required this.scheduler});

  @override
  State<MonthlySchedulerEditPicker> createState() =>
      _MonthlySchedulerEditPickerState();
}

class _MonthlySchedulerEditPickerState
    extends State<MonthlySchedulerEditPicker> {
  late int _selectedDay;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.scheduler.dayOfMonth!;
    _selectedTime = _parseTime(widget.scheduler.reminderTime!);
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFA7AAE1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // DAY PICKER (1–28)
          DropdownButton<int>(
            value: _selectedDay,
            isExpanded: true,
            dropdownColor: const Color(0xFFA7AAE1),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            underline: Container(),
            items: List.generate(
              28,
                  (i) => DropdownMenuItem(
                value: i + 1,
                child: Text("Day ${i + 1}"),
              ),
            ),
            onChanged: (value) {
              setState(() => _selectedDay = value!);
            },
          ),

          Divider(color: Colors.black, height: 5, thickness: 1),

          // TIME PICKER
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (newTime != null) {
                setState(() => _selectedTime = newTime);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Icon(Icons.access_time, color: Colors.black),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedTime == _parseTime(widget.scheduler.reminderTime!) &&
                    _selectedDay == widget.scheduler.dayOfMonth) {
                  showErrorDialog(
                    context: context,
                    title: "Error",
                    errors: ["No changes were made to the scheduler"],
                  );
                  return;
                }

                final newTime =
                    "${_selectedTime.hour.toString().padLeft(2, '0')}:"
                    "${_selectedTime.minute.toString().padLeft(2, '0')}:00";

                bool? isAccept = await ConfirmationPopup.show(
                  context,
                  "Are you sure you want to save changes?",
                );

                if (isAccept == true) {
                  Navigator.pop(context, {
                    "id": widget.scheduler.id,
                    "dayOfMonth": _selectedDay,
                    "reminderTime": newTime,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
