import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/base/period_type_enum.dart';
import 'package:habit_tracker_mobile/services/auth_service.dart';
import 'package:habit_tracker_mobile/services/firebase_service.dart';
import 'package:habit_tracker_mobile/services/habit_service.dart';
import 'package:habit_tracker_mobile/widgets/info_card.dart';
import 'package:habit_tracker_mobile/widgets/Schedulers/WeeklyScheduler/weekly_scheduler_picker.dart';
import '../models/Habit/habit_dto.dart';
import '../models/HabitGroup/habit_group_dto.dart';
import '../models/Schedulers/WeeklyScheduler/weekly_scheduler_dto.dart';
import '../services/scheduler_service.dart';
import '../utils/day_converter.dart';
import '../utils/time_format.dart';
import '../widgets/PopUp/confirmation_popup.dart';
import '../widgets/PopUp/error_response_popup.dart';
import '../widgets/Habit/habit_form.dart';
import '../widgets/Schedulers/WeeklyScheduler/weekly_scheduler_update_form.dart';
import '../widgets/animated_card.dart';
import 'group_inside_screen.dart';
import 'habit_list_screen.dart';

final GlobalKey<AnimatedStreakCardState> streakCardKey = GlobalKey<AnimatedStreakCardState>();

class WeeklySchedulerScreen extends StatefulWidget {
  final HabitDto habit;
  final HabitGroupDto habitGroup;

  const WeeklySchedulerScreen({
    super.key,
    required this.habit,
    required this.habitGroup,
  });

  @override
  State<WeeklySchedulerScreen> createState() => _WeeklySchedulerScreenState();
}

class _WeeklySchedulerScreenState extends State<WeeklySchedulerScreen> {
  final _authService = AuthService();
  final _schedulerService = SchedulerService();
  final _habitService = HabitService();
  final _firebaseService = FirebaseService();

  bool _isLoading = false;
  HabitDto? _habit;
  List<WeeklySchedulerDto> _habitSchedulers = [];

  bool _isEditingNote = false;
  late TextEditingController _noteController;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    _habit = widget.habit;
    _noteController = TextEditingController(text: _habit!.notes ?? "");
    getHabitSchedulers(_habit!.id!);
  }

  void showUpdateSheet(BuildContext context) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    HabitDto? _updatedHabit = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitForm(habit: _habit,isUpdate: true,),
    );

    if(_updatedHabit != null &&
        (_updatedHabit.frequency != _habit!.frequency ||
            _updatedHabit.periodType != _habit!.periodType)
    ){
      setState(() {
        _habit = _updatedHabit;
        _habitSchedulers = [];
        getHabitSchedulers(_habit!.id!);
        _habitSchedulers.sort((a, b) => a.reminderTime!.compareTo(b.reminderTime!));
      });
    }
    else if(_updatedHabit != null){
      setState(() {
        _habit = _updatedHabit;
      });
    }
  }

  Future<void> deleteHabit(String habitId) async {
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

    var response = await _habitService.deleteHabitAsync(habitId);

    if(response.isSuccess && response.statusCode == 200){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder:(context) => GroupInsideScreen(habitGroup: widget.habitGroup))
      );
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

  Future<bool> completeScheduler(String schedulerId) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return false;
    }

    setState(() {
      _isLoading = true;
    });

    var response = await _schedulerService.completeWeeklySchedulerAsync(schedulerId);

    if(response.isSuccess && response.statusCode == 200){
      setState(() {
        _isLoading = false;
      });
      return true;
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
      return false;
    }
  }

  Future<void> getHabitSchedulers(String habitId) async {
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
    final response = await _schedulerService.getWeeklySchedulersAsync(widget.habit.id!);

    if (response.isSuccess && response.data != null) {
      setState(() {
        _habitSchedulers = response.data!.items;
        _habitSchedulers.sort((a, b) => a.dayOfWeek!.compareTo(b.dayOfWeek!));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> updateScheduler({
    required String id,
    required String reminderTime,
    required int dayOfWeek
  }) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if(!isAuthenticated){
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return false;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _schedulerService.updateWeeklySchedulerAsync(
          id: id,
          dayOfWeek: dayOfWeek,
          reminderTime: reminderTime
      );
      if (response.isSuccess || response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Scheduler updated.",
              style: TextStyle(color: Colors.black)
            ),
            backgroundColor: Colors.greenAccent,
            duration: Duration(milliseconds: 800),
          ),
        );
      } else {
        showErrorDialog(
          context: context,
          title: "Güncelleme Başarısız",
          errors: response.errors ??
              [response.message ?? "Bilinmeyen bir hata oluştu."],
        );
        setState(() => _isLoading = false);
        return false;
      }
    } catch (err) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString()),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7AAE1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA7AAE1),
        centerTitle: true,
        title: Text(
          _habit!.name ?? "Habit Details",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: "Geri",
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GroupInsideScreen(habitGroup: widget.habitGroup)));
          },
        ),
        actions: [
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

            icon: const Icon(Icons.more_horiz, color: Colors.black),

            onSelected: (value) async {
              if (value == 'update') {
                showUpdateSheet(context);
              } else if (value == 'delete') {
                bool? isAccept = await ConfirmationPopup.show(
                    context, "Are you sure you want to delete this habit?");
                if (isAccept == true) {
                  deleteHabit(_habit!.id!);
                }
              }
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
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // üst bilgi kartı
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30,10,30,10),
                    decoration: BoxDecoration(
                      color: _habit!.isActive == true
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Status : ${_habit!.isActive == true ? "Active" : "Inactive"}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            infoCard(
              icon: Icons.calendar_today,
              label: "Period Type",
              value: _habit!.periodType?.displayName ?? "Unknown",
            ),
            infoCard(
              icon: Icons.repeat,
              label: "Frequency",
              value: _habit!.frequency?.toString() ?? "-",
            ),
            AnimatedStreakCard(
              key: streakCardKey,
              icon: Icons.local_fire_department,
              label: "Streak",
              value: "${_habit!.streak} weeks",
              subtitle: "Best Streak: ${_habit!.bestStreak} weeks",
            ),
            infoCard(
              icon: Icons.date_range,
              label: "Started Date",
              value: _habit!.createdDate != null
                  ? "${_habit!.createdDate!.day}/${_habit!.createdDate!.month}/${_habit!.createdDate!.year}"
                  : "Unknown",
            ),
            const SizedBox(height: 3),

            //note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst satır (Notes + butonlar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notes",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isEditingNote ? Icons.check : Icons.edit,
                              color: Colors.deepPurple,
                            ),
                            tooltip: _isEditingNote ? "Save note" : "Edit note",
                            onPressed: () async {
                              if (_isEditingNote) {
                                final newNote = _noteController.text.trim();
                                final response = await _habitService.updateHabitNoteAsync(
                                    _habit!.id!,
                                    newNote
                                );
                                if(response.statusCode == 200){
                                  setState(() {
                                    _noteController.text = newNote;
                                    _habit!.notes =  newNote;
                                    _isEditingNote = false;
                                  });
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.errors![0],
                                          style: TextStyle(color: Colors.black)),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(milliseconds: 1000),
                                    ),
                                  );
                                }
                              } else {
                                setState(() {
                                  _isEditingNote = true;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            tooltip: "Delete note",
                            onPressed: () async {
                              if(_habit!.notes != null && _habit!.notes != "") {
                                final response = await _habitService
                                    .updateHabitNoteAsync(
                                    _habit!.id!,
                                    ""
                                );
                                if (response.statusCode == 200) {
                                  setState(() {
                                    _noteController.text = "";
                                    _habit!.notes = "";
                                    _isEditingNote = false;
                                  });
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.errors![0],
                                          style: TextStyle(
                                              color: Colors.black)),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  _isEditingNote
                    ? Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: Colors.deepPurple, width: 1.5),
                          right: BorderSide(color: Colors.deepPurple, width: 1.5),
                        ),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: null,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    )
                  : Text(
                    (_habit!.notes == null || _habit!.notes!.trim().isEmpty)
                        ? "No notes added for this habit."
                        : _habit!.notes!,
                    style: const TextStyle(fontSize: 16),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text("SCHEDULERS",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
            ),

            //ACTIVATE HABIT
            if(!widget.habit.isActive! || _habitSchedulers.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(child: Text("No schedulers found out for this habit")),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          final bool? isSucceed= await showModalBottomSheet<bool>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Color(0xFFA7AAE1),
                            builder: (context) => SimpleWeeklyPicker(habit: _habit!),
                          );
                          if(isSucceed != null && isSucceed){
                            setState(() {
                              getHabitSchedulers(_habit!.id!);
                              _habit!.isActive = true;
                            });
                          }
                          else {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.black,
                                width: 2,
                              )
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.alarm_on, color: Colors.black),
                              SizedBox(width: 4),
                              Text("Activate Habit", style: TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ]
              )
            else if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _habitSchedulers.length,
                    itemBuilder: (context, index) {
                      final scheduler = _habitSchedulers[index];

                      return Container(

                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.deepPurple, size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(scheduler.reminderTime!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getDayName(scheduler.dayOfWeek!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.deepPurple),
                              onPressed: () async {
                                final result = await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => WeeklySchedulerEditPicker(scheduler: scheduler),
                                );
                                if (result != null) {
                                  bool isOk = await updateScheduler(
                                    id: scheduler.id!,
                                    dayOfWeek: result["dayOfWeek"],
                                    reminderTime: result["reminderTime"]
                                  );
                                  if(isOk){
                                    setState(() {
                                      getHabitSchedulers(scheduler.habitId!);
                                    });
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                (scheduler.isDone ?? false) ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () async {
                                if(!(scheduler.isDone ?? false)){
                                  bool? isMarked = await ConfirmationPopup.show(context, "Are you sure to mark this scheduler as done? "
                                      "There will be no return for this scheduler!");
                                  if(isMarked!){
                                    bool isChecked = await completeScheduler(scheduler.id!);
                                    if(isChecked){
                                      scheduler.isDone = true;
                                      bool isAllDone = _habitSchedulers
                                          .every((scheduler) => scheduler.isDone == true);
                                      if(isAllDone){
                                        _habit!.bestStreak = _habit!.bestStreak! + 1;
                                        _habit!.streak = _habit!.streak! + 1;

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          streakCardKey.currentState?.triggerPlusOne();
                                        });
                                      }
                                      setState(() {});
                                    }
                                  }
                                }
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}