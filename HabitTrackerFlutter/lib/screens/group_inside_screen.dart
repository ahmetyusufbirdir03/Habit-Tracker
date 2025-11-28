import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/screens/special_reminders_screen.dart';
import 'habit_list_screen.dart';
import '../models/HabitGroup/habit_group_dto.dart';
import '../widgets/BottomSlideBar.dart';
import 'home_screen.dart'; // Özel bottom bar widget

class GroupInsideScreen extends StatefulWidget {
  final HabitGroupDto habitGroup;
  const GroupInsideScreen({super.key, required this.habitGroup});

  @override
  State<GroupInsideScreen> createState() => _GroupInsideScreenState();
}

class _GroupInsideScreenState extends State<GroupInsideScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA7AAE1),
        title: Text(
          widget.habitGroup.name ?? "HABITS",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 1)),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            HabitListScreen(habitGroup: widget.habitGroup),
            SpecialRemindersScreen(habitGroup: widget.habitGroup),
          ],
        ),
      ),
      bottomNavigationBar: BottomIndicatorBar(
        selectedIndex: _selectedIndex,
        onButtonPressed: _onTabSelected,
        leftButtonName: "SPECIAL REMINDERS",
        rightButtonName: "HABITS",
        barColor: const Color(0xFFA7AAE1),
        selectedTextColor: Colors.black,
        unselectedTextColor: Colors.black45,
      ),
    );
  }
}

class SpecificReminderScreen {
}
