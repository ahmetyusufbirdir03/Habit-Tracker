import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/SecialReminder/SpecialReminderDto.dart';
import 'package:habit_tracker_mobile/services/special_reminder_service.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/confirmation_popup.dart';
import '../../base/month_enum.dart';
import '../PopUp/error_response_popup.dart';

class SpecialReminderForm extends StatefulWidget {
  final bool isUpdate;
  final SpecialReminderDto? reminder;
  final String? habitGroupId;

  const SpecialReminderForm({
    super.key,
    this.isUpdate = false,
    this.reminder,
    this.habitGroupId,
  });

  @override
  State<SpecialReminderForm> createState() => _SpecialReminderFormState();
}

class _SpecialReminderFormState extends State<SpecialReminderForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _reminderService = SpecialReminderService();

  int? selectedDay;
  Month? selectedMonth;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.isUpdate && widget.reminder != null) {
      _titleController.text = widget.reminder!.title ?? '';
      selectedMonth = MonthExtension.fromInt(widget.reminder!.month ?? 1);
      _descriptionController.text = widget.reminder!.description ?? '';
      selectedDay = widget.reminder!.day ?? 1;
    }
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isUpdate && widget.reminder != null) {
        // final response = await _reminderService.updateReminderAsync(
        //   id: widget.reminder!.id!,
        //   title: _titleController.text.isEmpty ? null : _titleController.text,
        //   month: selectedMonth!.value,
        //   day: selectedDay,
        //   description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        // );
        // setState(() {
        //   _isLoading = false;
        // });
        //
        // if (response.isSuccess || response.statusCode == 200) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("Habit updated successfully.",
        //           style: TextStyle(color: Colors.black)),
        //       backgroundColor: Colors.greenAccent,
        //       duration: Duration(milliseconds: 800),
        //     ),
        //   );
        //   setState(() {
        //     _updatedReminder = response.data;
        //   });
        //   Navigator.pop(context, _updatedReminder);
        // } else {
        //   showErrorDialog(
        //     context: context,
        //     title: "Update failed.",
        //     errors: response.errors ??
        //         [response.message ?? "Bilinmeyen bir hata oluştu."],
        //   );
        // }
      } else {
        final response = await _reminderService.createSpecialReminderAsync(
          title: _titleController.text.isEmpty ? null :  _titleController.text,
          month: selectedMonth?.value,
          day: selectedDay,
          habitGroupId: widget.habitGroupId!,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );
        setState(() {
          _isLoading = false;
        });
        if (response.isSuccess || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Habit created successfully.",
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.greenAccent,
              duration: Duration(milliseconds: 800),
            ),
          );
          Navigator.pop(context, true);
        } else {
          showErrorDialog(
            context: context,
            title: "Creation failed.",
            errors: response.errors ??
                [response.message ?? "Bilinmeyen bir hata oluştu."],
          );
        }
      }
    } catch (err) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFA7AAE1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Center(
              child: Text(
                widget.isUpdate ? "Update Reminder" : "Create New Reminder",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // Reminder Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Reminder Name (optional)",
                filled: true,
                fillColor: Color(0xFFD3D7F0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
                floatingLabelStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Day of the month dropdown
            DropdownButtonFormField<int>(
              initialValue: selectedDay,
              decoration: const InputDecoration(
                labelText: "Reminder Day (optional)",
                filled: true,
                fillColor: Color(0xFFD3D7F0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
                floatingLabelStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: List.generate(31, (index) => index + 1)
                .map((value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                )).toList(),
              onChanged: (value) => setState(() => selectedDay = value!),
            ),
            const SizedBox(height: 12),

            // Month dropdown
            DropdownButtonFormField<Month>(
              initialValue: selectedMonth,
              decoration: const InputDecoration(
                labelText: "Reminder Month",
                filled: true,
                fillColor: Color(0xFFD3D7F0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              items: Month.values
                .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.displayName),
                )).toList(),

              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                });
              },
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                filled: true,
                fillColor: Color(0xFFD3D7F0),
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
                floatingLabelStyle: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "*You can leave fields empty if optional",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if(widget.isUpdate &&
                      (widget.reminder!.month != selectedMonth!.value ||
                          widget.reminder!.day != selectedDay
                      )
                  ) {
                    bool? isOk = await ConfirmationPopup.show(context,
                        "If you change period type or frequency, "
                            "the habit will be inactive and schedulers are going to be deleted.\n"
                            "Are you sure to update this habit?");
                    if(isOk ?? true){
                      _submit();
                    }
                  }
                  else if(widget.isUpdate){
                    bool? isOk = await ConfirmationPopup.show(context,
                        "Are you sure to update this habit?");
                    if(isOk ?? true){
                      _submit();
                    }
                  }
                  else{
                    _submit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFFD3D7F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Colors.deepPurple,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  widget.isUpdate ? "Update" : "Create",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
