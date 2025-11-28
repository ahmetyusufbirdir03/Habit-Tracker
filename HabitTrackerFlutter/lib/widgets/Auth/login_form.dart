import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';
import '../PopUp/error_response_popup.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final tokenService = TokenService();
  final authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    if(_emailController.text.isEmpty || _passwordController.text.isEmpty){
      setState(() {
        _errorMessage = 'Lütfen tüm zorunlu alanları doldurun.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var response;
    // login request
    try {
      response = await authService.loginAsync(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }catch(err){
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

    if(response != null && response.isSuccess && response.data != null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Giriş Başarılı!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),

          ),
          backgroundColor: Colors.greenAccent,
          duration: Duration(milliseconds: 500),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomeScreen()));

    }else {
      showErrorDialog(
        context: context,
        title: 'İşlem Başarısız',
        errors: response.errors ?? [response.message ?? 'Bilinmeyen bir hata oluştu.']
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Email'),
            obscureText: false,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            controller: _passwordController
          ,),
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
            onPressed: _login,
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}