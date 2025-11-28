import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/services/habit_service.dart';
import 'package:habit_tracker_mobile/widgets/PopUp/confirmation_popup.dart';
import '../PopUp/error_response_popup.dart';
import '../../base/period_type_enum.dart';
import '../../models/Habit/habit_dto.dart';

class HabitForm extends StatefulWidget {
  final selectedType;
  final bool isUpdate;
  final HabitDto? habit;
  final String? habitGroupId;

  const HabitForm({
    super.key,
    this.isUpdate = false,
    this.habit,
    this.habitGroupId,
    this.selectedType
  });

  @override
  State<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
  final _nameController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _notesController = TextEditingController();
  final _habitService = HabitService();
  HabitDto? _updatedHabit;

  bool _isLoading = false;
  String? _errorMessage;

  PeriodType? _selectedPeriod;

  String warningMessage =
      "If you change period type or frequency:\n"
      "\t-The habit will be inactive\n"
      "\t-Streaks are going to be reset\n"
      "\t-Schedulers are going to be deleted\n"
      "Are you sure to update this habit?";


  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedType;

    if (widget.isUpdate && widget.habit != null) {
      _nameController.text = widget.habit!.name ?? '';
      _frequencyController.text = widget.habit!.frequency?.toString() ?? '';
      _notesController.text = widget.habit!.notes ?? '';
      _selectedPeriod = widget.habit!.periodType ?? PeriodType.daily;
    }
  }
  void _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isUpdate && widget.habit != null) {
        final response = await _habitService.updateHabitAsync(
          id: widget.habit!.id!,
          name: _nameController.text.isEmpty ? null : _nameController.text,
          periodType: _selectedPeriod!.value,
          frequency: int.tryParse(_frequencyController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        setState(() {
          _isLoading = false;
        });
        if (response.isSuccess || response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Habit updated successfully.",
              style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.greenAccent,
              duration: Duration(milliseconds: 800),
            ),
          );
          setState(() {
            _updatedHabit = response.data;
          });
          Navigator.pop(context, _updatedHabit);
        } else {
          showErrorDialog(
            context: context,
            title: "Update failed.",
            errors: response.errors ??
                [response.message ?? "Bilinmeyen bir hata oluştu."],
          );
        }
      } else {
        final response = await _habitService.createHabitAsync(
          name: _nameController.text,
          periodType: _selectedPeriod,
          frequency: int.tryParse(_frequencyController.text),
          habitGroupId: widget.habitGroupId!,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
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
              widget.isUpdate ? "Update Habit" : "Create New Habit",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),

          // Habit name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Habit Name (optional)",
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

          // Period Type dropdown
          DropdownButtonFormField<PeriodType>(
            value: _selectedPeriod,
            decoration: const InputDecoration(
              labelText: "Period Type (optional)",
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
            items: PeriodType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedPeriod = value!),
          ),
          const SizedBox(height: 12),

          // Frequency
          TextField(
            controller: _frequencyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Frequency (e.g., 3) (optional)",
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

          // Notes
          TextField(
            controller: _notesController,
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
              onPressed: () async {
                if(widget.isUpdate &&
                    (widget.habit!.periodType != _selectedPeriod ||
                        widget.habit!.frequency != int.tryParse(_frequencyController.text)
                    )
                ) {
                  bool? isOk = await ConfirmationPopup.show(context,
                      warningMessage);
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
                widget.isUpdate ? "Update" : "Save",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
