import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/Schedulers/WeeklyScheduler/weekly_scheduler_dto.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/confirmation_popup.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/error_response_popup.dart';

class WeeklySchedulerEditPicker extends StatefulWidget {
  final WeeklySchedulerDto scheduler;

  const WeeklySchedulerEditPicker({super.key, required this.scheduler});

  @override
  State<WeeklySchedulerEditPicker> createState() => _WeeklySchedulerEditPickerState();
}

class _WeeklySchedulerEditPickerState extends State<WeeklySchedulerEditPicker> {

  late int _selectedDay;
  late TimeOfDay _selectedTime;
  bool _isLoading = false;

  final Map<int, String> dayMap = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday",
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.scheduler.dayOfWeek!;
    _selectedTime = parseTime(widget.scheduler.reminderTime!);
  }

  TimeOfDay parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFA7AAE1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
          DropdownButton<int>(
            value: _selectedDay,
            isExpanded: true,
            dropdownColor: Color(0xFFA7AAE1),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            underline: Container(),
            items: dayMap.entries
                .map((entry) => DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedDay = value!);
            },
          ),
          Divider(
            color: Colors.black,
            height: 5,
            thickness: 1,
          ),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                  const Icon(Icons.access_time, color: Colors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async{
                if(_selectedTime == parseTime(widget.scheduler.reminderTime!)  && _selectedDay == widget.scheduler.dayOfWeek){
                  showErrorDialog(
                      context: context,
                      title: "Error",
                      errors: ["No changes were made to the scheduler"]
                  );
                }
                else {
                  final newTime =
                      "${_selectedTime.hour.toString().padLeft(2,'0')}:"
                      "${_selectedTime.minute.toString().padLeft(2,'0')}:00";

                  bool? isAccept = await ConfirmationPopup.show(context, "Are you sure you want to save changes");

                  if(isAccept!) {
                    Navigator.pop(context, {
                      "id": widget.scheduler.id,
                      "dayOfWeek": _selectedDay,
                      "reminderTime": newTime,
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.deepPurple),),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
