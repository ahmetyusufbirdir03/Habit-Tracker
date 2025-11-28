import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/screens/home_screen.dart';
import 'package:habit_tracker_mobile/services/token_service.dart';
import '../../services/auth_service.dart';
import '../PopUp/error_response_popup.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final tokenService = TokenService();
  final authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  void _register() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen tüm zorunlu alanları doldurun.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var response ;
    try {
      response = await authService.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneController.text,
      );
    }
    catch(err){
      setState(() {
        _isLoading = false;
      });
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

    if (response.isSuccess && response.data != null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           duration: Duration(seconds: 1),
           content:
           Text('Welcome to Habit Tracker',
             style: TextStyle(
               color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.greenAccent,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomeScreen()));
    } else {
      final errorsToShow = response.errors ?? [];
      showErrorDialog(
        context: context,
        title: 'İşlem Başarısız',
        errors: errorsToShow.isNotEmpty
            ? errorsToShow
            : [response.message ?? 'Bilinmeyen bir hata oluştu.'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
           TextField(
              decoration: InputDecoration(labelText: 'Username'),
              obscureText: false,
              controller: _usernameController),
          const SizedBox(height: 16),
           TextField(
               decoration: InputDecoration(labelText: 'Phone Number'),
               obscureText: false,
               controller: _phoneController
           ),
          const SizedBox(height: 16),
           TextField(
               decoration: InputDecoration(labelText: 'Email'),
               obscureText: false,
               controller: _emailController),
          const SizedBox(height: 16),
           TextField(
               decoration: InputDecoration(labelText: 'Password'),
               obscureText: true,
               controller: _passwordController),
          const SizedBox(height: 32),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 32),

          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _register,
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}