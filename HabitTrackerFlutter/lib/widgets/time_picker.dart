import 'package:flutter/material.dart';

class TimePicker extends StatefulWidget {
  final int frequency;
  const TimePicker({super.key, required this.frequency});

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late List<TimeOfDay?> pickedTimes;

  @override
  void initState() {
    super.initState();
    pickedTimes = List.generate(widget.frequency, (_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            "Select Reminder Times",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.frequency,
            itemBuilder: (context, index) {
              final time = pickedTimes[index];
              final displayText = time != null
                  ? "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}"
                  : "Select time";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, // beyaz arkaplan
                  borderRadius: BorderRadius.circular(12), // köşe yuvarlama
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, color: Colors.deepPurple),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Reminder ${index + 1}: $displayText",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) {
                          setState(() {
                            pickedTimes[index] = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (pickedTimes.any((t) => t == null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select all times")),
                );
                return;
              }

              final timesString = pickedTimes
                  .map((t) =>
              "${t!.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}:00")
                  .toList();

              Navigator.of(context).pop(timesString);
            },
            child: const Text("Confirm",style: TextStyle(color: Colors.black),),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
