import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/screens/user_profile_screen.dart';
import '../services/token_service.dart';
import '../widgets/BottomSlideBar.dart';
import 'habit_groups_screen.dart';

class HomeScreen extends StatefulWidget {
  int? selectedIndex;
  HomeScreen({super.key,this.selectedIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _pageIndex;
  final tokenService = TokenService();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _pageIndex ?? 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onButtonPressed(int index) {
    setState(() {
      _pageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          children: const [
            UserProfile(),
            HabitGroupsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomIndicatorBar(
        selectedIndex: _pageIndex ?? 0,
        onButtonPressed: _onButtonPressed,
        rightButtonName: "PROFILE",
        leftButtonName: "HABIT GROUPS",
        barColor: const Color(0xFFA7AAE1),
        selectedTextColor: Colors.black,
        unselectedTextColor: Colors.black45,
      ),
    );
  }
}
