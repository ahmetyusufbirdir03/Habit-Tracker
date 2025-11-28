import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/base/logger.dart';
import 'package:habit_tracker_mobile/widgets/BottomSlideBar.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../widgets/Auth/login_form.dart' show LoginForm;
import '../widgets/Auth/register_form.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  int _selectedIndex = 1;
  final tokenService = TokenService();
  final _logger = logger;

  @override
  void initState() {
    super.initState();
    checkAuthAsync();
  }
  void checkAuthAsync() async {
    final isAuthenticated = await _authService.checkAuthStatusAsync();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _logger.i("Kullanıcı doğrulanmadı. Login ekranında kalınıyor.");
    }
  }

  Widget get _currentAuthForm {
    if (_selectedIndex == 0) {
      return const RegisterForm();
    } else {
      return const LoginForm();
    }
  }
  void _onButtonPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _selectedIndex == 0 ? 'SIGN IN' : 'LOGIN';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFA7AAE1),
      ),
      body: _currentAuthForm,
      bottomNavigationBar: BottomIndicatorBar(
        selectedIndex: _selectedIndex,
        onButtonPressed: _onButtonPressed,
        rightButtonName: "SIGN IN",
        leftButtonName: "LOGIN",
        barColor: Color(0xFFA7AAE1),
        selectedTextColor: Colors.black,
        unselectedTextColor: Colors.grey.shade800,
      ),
    );
  }
}
