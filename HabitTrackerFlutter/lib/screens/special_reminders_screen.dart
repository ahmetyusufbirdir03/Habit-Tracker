import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/base/logger.dart';
import 'package:habit_tracker_mobile/models/HabitGroup/habit_group_dto.dart';
import 'package:habit_tracker_mobile/models/SecialReminder/SpecialReminderDto.dart';
import 'package:habit_tracker_mobile/services/special_reminder_service.dart';
import 'package:habit_tracker_mobile/utils/time_format.dart';
import 'package:habit_tracker_mobile/widgets/SpecialReminder/SpecialReminderForm.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/PopUp/confirmation_popup.dart';
import '../widgets/PopUp/error_response_popup.dart';

class SpecialRemindersScreen extends StatefulWidget {
  final HabitGroupDto habitGroup;
  const SpecialRemindersScreen({super.key, required this.habitGroup});

  @override
  State<SpecialRemindersScreen> createState() => _SpecialRemindersScreenState();
}
class _SpecialRemindersScreenState extends State<SpecialRemindersScreen> {
  final _authService = AuthService();
  final _specialReminderService = SpecialReminderService();
  final _firebaseService = FirebaseService();

  List<SpecialReminderDto> _specialReminders = [];
  bool _isLoading = false;

  String? _selectedSort;
  final List<String> _sortOptions = [
    "Tarih ▼",
    "Tarih ▲",
    "Alfabetik ▼",
    "Alfabetik ▲",
  ];

  @override
  initState() {
    super.initState();
    getSpecialReminders();
  }
  void _sortHabitGroups() {
    setState(() {
      switch (_selectedSort) {
        case "Tarih ▼":
          _specialReminders.sort((a, b) {
            final d1 = getSortDate(a) ;
            final d2 = getSortDate(b);

            if (d1 == null) return -1;
            if (d2 == null) return 1;

            return d1.compareTo(d2);
          });
          break;

        case "Tarih ▲":
          _specialReminders.sort((a, b) {
            final d1 = getSortDate(a);
            final d2 = getSortDate(b);

            if (d1 == null) return 1;
            if (d2 == null) return -1;

            return d2.compareTo(d1);
          });
          break;

        case "Alfabetik ▼":
          _specialReminders.sort((a, b) => a.title!.compareTo(b.title!));
          break;

        case "Alfabetik ▲":
          _specialReminders.sort((a, b) => b.title!.compareTo(a.title!));
          break;
      }
    });
  }

  DateTime? getSortDate(SpecialReminderDto r) {
    final result = formatDayMonth(day: r.day!, month: r.month!);

    // Geçersiz tarih varsa null döndür
    if (result.date == null) return null;

    // Saat kısmını sıfırla, sadece tarih kalır
    return DateTime(result.date!.year, result.date!.month, result.date!.day);
  }

  Future<void> getSpecialReminders() async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final response = await _specialReminderService.getSpecialRemindersAsync(widget.habitGroup.id!);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _specialReminders = response.data!.items;
        _specialReminders.sort((a, b) {
          final d1 = getSortDate(a);
          final d2 = getSortDate(b);

          if (d1 == null) return -1;
          if (d2 == null) return 1;

          return d1.compareTo(d2);
        });
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showReminderSheet(BuildContext context,{SpecialReminderDto? reminder, bool? isUpdate}) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    var isSuccess = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpecialReminderForm(
        isUpdate: isUpdate ?? false,
        habitGroupId: widget.habitGroup.id,
        reminder: reminder,
      ),
    );
    if (isSuccess) {
      setState(() {
        getSpecialReminders();
      });
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var response = await _specialReminderService.deleteSpecialReminderAsync(reminderId);

    if(response.isSuccess && response.statusCode == 200){
      setState(() {
        _specialReminders.removeWhere((r) => r.id == reminderId);
      });
    }
    else {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(
          context: context,
          title: 'Error',
          errors: response.errors ?? [response.message ?? 'Bilinmeyen bir hata oluştu.']
      );
    }
  }

  void _handleMenuSelection(String value, SpecialReminderDto reminder) async {
    if (value == 'update') {
      showReminderSheet(context, reminder: reminder, isUpdate: true);
    } else if (value == 'delete') {
      bool? isAccept = await ConfirmationPopup.show(
          context, "Are you sure you want to delete this reminder?");
      if (isAccept == true) {
        deleteReminder(reminder.id!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7AAE1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 5,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => showReminderSheet(context, isUpdate: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.black),
                          SizedBox(width: 4),
                          Text("New Reminder",
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: SizedBox(
                      height: 56,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
                          hintText: "Sort",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: _sortOptions.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal == null) return;
                          setState(() {
                            _selectedSort = newVal;
                            _sortHabitGroups();
                          });
                        },
                      )
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _specialReminders.isEmpty
                ? const Center(
                  child: Text(
                    "No special reminders found.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                : ListView.separated(
                itemCount: _specialReminders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final reminder = _specialReminders[index];
                  final r = formatDayMonth(day: reminder.day!, month: reminder.month!);
                  logger.i("Date : ${r.date}");
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              reminder.title!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.deepPurple,
                                  width: 1,
                                ),
                              ),
                              color: Colors.white,
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_horiz, color: Colors.deepPurple),
                              onSelected: (value) async {
                                _handleMenuSelection(value, reminder);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'update',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.deepPurple, size: 20),
                                      SizedBox(width: 8),
                                      Text('Update'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(
                          color: Colors.deepPurple,
                          thickness: 1,
                          endIndent: 10,
                        ),
                        SizedBox(height: 10),
                        if (r.error != null)
                          Text(
                            "Date : ${r.error!}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            "Date: ${DateFormat('dd MMMM yyyy').format(r.date!)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          reminder.description ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}
