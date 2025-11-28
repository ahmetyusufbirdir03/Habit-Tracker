import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/base/period_type_enum.dart';
import 'package:habit_tracker_mobile/models/HabitGroup/habit_group_dto.dart';
import 'package:habit_tracker_mobile/models/Habit/habit_dto.dart';
import 'package:habit_tracker_mobile/screens/habit_screen.dart';
import 'package:habit_tracker_mobile/services/auth_service.dart';
import 'package:habit_tracker_mobile/services/firebase_service.dart';
import 'package:habit_tracker_mobile/services/habit_service.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/Habit/habit_form.dart';

class HabitListScreen extends StatefulWidget {
  final HabitGroupDto habitGroup;
  const HabitListScreen({super.key, required this.habitGroup});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  final _authService = AuthService();
  final _habitService = HabitService();
  final _firebaseService = FirebaseService();
  late List<PeriodType> _periodOptions;


  List<HabitDto> _habits = [];
  bool _isLoading = false;

  PeriodType _activePeriod = PeriodType.daily;


  @override
  void initState() {
    super.initState();
    _periodOptions = PeriodType.values;
    _loadActivePeriod();
    _getHabitsAsync();
  }

  Future<void> _saveActivePeriod(PeriodType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_active_period', type.index);
  }

  Future<void> _loadActivePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('last_active_period');

    setState(() {
      _activePeriod = savedIndex != null
          ? PeriodType.values[savedIndex]
          : PeriodType.daily;
    });
  }

  Future<void> _getHabitsAsync() async {
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

    final response = await _habitService.getHabitsAsync(widget.habitGroup.id!);

    if (response.isSuccess && response.data != null) {
      setState(() {
        _habits = response.data!.habitList;
        _habits.sort((a, b) => a.createdDate!.compareTo(b.createdDate!));
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<HabitDto> get _filteredHabits {
    final filtered = _habits
        .where((h) => h.periodType == _activePeriod)
        .toList();
    return filtered;
  }

  void showCreateHabitSheet(BuildContext context) async {
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
      builder: (context) => HabitForm(habitGroupId: widget.habitGroup.id!,selectedType: _activePeriod),
    );
    if (isSuccess) {
      setState(() {
        _getHabitsAsync();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsToShow = _filteredHabits;

    return Scaffold(
      backgroundColor: const Color(0xFFA7AAE1),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 5,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => showCreateHabitSheet(context),
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
                            Text("New Habit",
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: SizedBox(
                        height: 56,
                        child: DropdownButtonFormField<PeriodType>(
                          isExpanded: true,
                          initialValue: _activePeriod,
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
                            hintText: "Period",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          ),
                          items: _periodOptions.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            if (newVal == null) return;
                            setState(() {
                              _activePeriod = newVal;
                            });
                            _saveActivePeriod(newVal);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if(_habits.isNotEmpty)...[
              // Liste Alanı
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 500),
                  reverse: _activePeriod.index <
                      PeriodType.values.indexOf(_activePeriod),
                  transitionBuilder: (Widget child, Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: const Color(0xFFA7AAE1),
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey(_activePeriod),
                    color: const Color(0xFFA7AAE1),
                    child: habitsToShow.isEmpty
                        ? const Center(
                      child: Text("Bu periyotta alışkanlık bulunmuyor."),
                    )
                        : ListView.separated(
                      itemCount: habitsToShow.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      itemBuilder: (context, index) {
                        final habit = habitsToShow[index];
                        return Card(
                          color: habit.isDone! ? Colors.greenAccent : Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            title: Text(
                              habit.name ?? "İsimsiz alışkanlık",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  "Note: " "${habit.notes ?? "No notes for this habit"}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HabitScreen(
                                    habit: habit,
                                    habitGroup: widget.habitGroup,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            ]
            else
              Expanded(
                child: Center(
                  child: Text("Bu grupta alışkanlık bulunmuyor."),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
