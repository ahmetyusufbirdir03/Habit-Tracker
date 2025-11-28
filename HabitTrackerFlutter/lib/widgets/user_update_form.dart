import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/services/user_service.dart';
import 'PopUp/error_response_popup.dart';


class UserUpdateForm extends StatefulWidget {
  final String userId;

  const UserUpdateForm({super.key, required this.userId});

  @override
  State<UserUpdateForm> createState() => _UserUpdateFormState();
}

class _UserUpdateFormState extends State<UserUpdateForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final userService = UserService();

  bool _isLoading = false;
  String? _errorMessage;

  void _updateProfile() async {

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await userService.updateUserAsync(
        id: widget.userId,
        username: _usernameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
      );

      setState(() => _isLoading = false);

      if (response.isSuccess || response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil başarıyla güncellendi."),
            backgroundColor: Colors.greenAccent,
            duration: Duration(milliseconds: 800),
          ),
        );
        Navigator.pop(context, true);
      } else {
        showErrorDialog(
          context: context,
          title: "Güncelleme Başarısız",
          errors: response.errors ??
              [response.message ?? "Bilinmeyen bir hata oluştu."],
        );
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
          const Center(
            child: Text(
              "Edit Your Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: "Username (optional)",
              filled: true,
              fillColor: Color(0xFFD3D7F0),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
              floatingLabelStyle: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email (optional)",
              filled: true,
              fillColor: Color(0xFFD3D7F0),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
              floatingLabelStyle: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: "Phone Number (optional)",
              filled: true,
              fillColor: Color(0xFFD3D7F0),
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
              floatingLabelStyle: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              "*You do not need to fill in all the fields",
              style: const TextStyle(color: Colors.black),
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
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Color(0xFFD3D7F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Colors.deepPurple,
                    width:3,
                  ),
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.black),),
            ),
          ),
        ],
      ),
    );
  }
}
