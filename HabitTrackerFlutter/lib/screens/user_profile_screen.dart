import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/user_dto.dart';
import 'package:habit_tracker_mobile/services/auth_service.dart';
import 'package:habit_tracker_mobile/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base/default_profile_picture.dart';
import '../base/kisWeb.dart';
import '../base/logger.dart';
import '../models/save_device_token_request_dto.dart';
import '../services/user_service.dart';
import '../services/user_session_service.dart';
import '../widgets/PopUp/error_response_popup.dart';
import '../widgets/PopUp/confirmation_popup.dart';
import '../widgets/PopUp/picture_url_popup.dart';
import '../widgets/user_update_form.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final Color white = Colors.white;
  final _authService = AuthService();
  final _userService = UserService();
  final _firebaseService = FirebaseService();
  final _logger = logger;

  UserDto? _user;
  String? _profilePictureUrl;

  bool _isLoading = false;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    getProfileAsync();
  }

  Future<void> saveDevice() async {
    var tokenResponse;
    try {
      final deviceToken = await _firebaseService.getToken();
      final deviceTokenRequest = SaveDeviceTokenRequestDto(
        userId: _user!.id,
        token: deviceToken ?? "",
        platform: platformName());
      tokenResponse = await _firebaseService.saveDeviceTokenAsync(deviceTokenRequest);

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

    if(tokenResponse.isSuccess || tokenResponse.statusCode == 200){
      _logger.i("Token kaydedildi");
    }else{
      await AuthService.logout(context);
      showErrorDialog(
          context: context,
          title: 'İşlem Başarısız',
          errors: tokenResponse.errors ?? [tokenResponse.message ?? 'Bilinmeyen bir hata oluştu.']
      );
    }
  }

  //PROFILE REQUEST
  void getProfileAsync() async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      _user = await UserSessionService().getUser();
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = "Kullanıcı bilgisi alınamadı. Lütfen tekrar deneyin.";
      });
    }
    if (_user == null ||
        _user?.id == null ||
        _user?.username == null ||
        _user?.email == null ||
        _user?.phoneNumber == null) {
      setState(() {
        _isLoading = false;
      });
    } else {
      await _loadProfileImageUrl(_user!.id);
      setState(() {
        _user = UserSessionService().currentUser;
        _isLoading = false;
        errorMessage = null;
      });
    }
    saveDevice();
  }

  //DELETE ACCOUNT
  Future<void> deleteAccount() async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    var response = await _userService.deleteUserAsync(_user!.id);

    if (response.isSuccess && response.statusCode == 200) {
      await AuthService.logout(context);
      logger.i("Kullanıcı başarıyla silindi.");
    } else {
      setState(() {
        _isLoading = false;
        errorMessage = response.message;
      });
      showErrorDialog(
        context: context,
        title: 'İşlem Başarısız',
        errors: response.errors ?? [response.message ?? 'Bilinmeyen bir hata oluştu.'],
      );
    }
  }

  //IMAGE PICKER
  Future<void> _pickUrl() async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    final result = await UrlInputDialog.show(context);
    if (result != null && _user != null) {
      setState(() {
        _profilePictureUrl = result;
      });
      await _saveProfileImageUrl(_user!.id, result);
    }
  }

  //IMAGE SAVE
  Future<void> _saveProfileImageUrl(String userId, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_url_$userId', url);
  }

  //IMAGE LOAD
  Future<void> _loadProfileImageUrl(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('profile_image_url_$userId');

    setState(() {
      _profilePictureUrl = (savedUrl != null && savedUrl.isNotEmpty)
          ? savedUrl
          : defaultProfilePictureUrl;
    });
  }

  //UPDATE FORM SHOW
  void showProfileUpdateSheet(BuildContext context) async {
    var isAuthenticated = await _authService.checkAuthStatusAsync();
    if (!isAuthenticated) {
      String? deviceTokenId = await _firebaseService.getToken();
      await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

      await AuthService.logout(context);
      return;
    }
    var isUpdateSuccess = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserUpdateForm(userId: _user!.id),
    );

    if (isUpdateSuccess) {
      getProfileAsync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7AAE1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? Stack(
                children: [
                  const Center(child: Text("Kullanıcı bilgileri bulunamadı")),
                  Positioned(
                    top: 100,
                    right: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: GestureDetector(
                          onTap: () async {
                            await AuthService.logout(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.logout, color: Color(0xFFD3D7F0), size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Logout",
                                  style: TextStyle(color: Color(0xFFD3D7F0), fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
              children: [
                platformName() == "Android" || platformName() == "iOS"
                    ? const SizedBox(height: 50)
                    : const SizedBox(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),

                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // PROFILE PICTURE
                                    Container(
                                      width: double.infinity,
                                      height: platformName() == "Android" || platformName() == "iOS" ? 250 : 380,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            (_profilePictureUrl != null &&
                                                _profilePictureUrl!.isNotEmpty &&
                                                _profilePictureUrl != "null")
                                                ? _profilePictureUrl!
                                                : defaultProfilePictureUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    // USERNAME TAG
                                    Positioned(
                                      bottom: 10,
                                      left: 70,
                                      right: 70,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _user!.username,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 6,
                                                    color: Colors.black.withOpacity(0.6),
                                                    offset: const Offset(1, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // LOGOUT BUTTON
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              bool? isOk = await ConfirmationPopup.show(
                                                context,
                                                "Are you sure you want to log out?",
                                              );
                                              if(isOk == true) {
                                                String? deviceTokenId = await _firebaseService.getToken();
                                                await _firebaseService.deleteDeviceTokenAsync(deviceTokenId);

                                                await AuthService.logout(context);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.logout, color: Colors.white, size: 20),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Logout",
                                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // UPDATE PICTURE BUTTON
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: ClipOval(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: GestureDetector(
                                            onTap: () async {
                                              _pickUrl();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.photo, color: Colors.white, size: 25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    textColor: Colors.black,
                                    leading: const Icon(Icons.badge_outlined, color: Colors.black),
                                    title: const Text("Id"),
                                    subtitle: Text(_user!.id),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.email),
                                    title: const Text("Email"),
                                    subtitle: Text(_user!.email),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.phone),
                                    title: const Text("Phone Number"),
                                    subtitle: Text(_user!.phoneNumber),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final editButton = Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    showProfileUpdateSheet(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit, color: Colors.black),
                                        SizedBox(width: 2),
                                        Text(
                                          "Edit Profile",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          final changePasswordButton = Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    // Password change logic
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.lock, color: Colors.black),
                                        SizedBox(width: 2),
                                        Text(
                                          "Change Password",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          final deleteButton = ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: GestureDetector(
                                onTap: () async {
                                  bool? result = await ConfirmationPopup.show(
                                    context,
                                    "Are you sure you want to delete your account?",
                                  );
                                  if (result == true) {
                                    deleteAccount();
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete, color: Colors.black),
                                      SizedBox(width: 8),
                                      Text(
                                        "Delete Account",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          return platformName() == "Windows" || platformName() == "Linux" || platformName() == "MacOS"
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 200, child: editButton),
                              const SizedBox(width: 16),
                              SizedBox(width: 200, child: changePasswordButton),
                              const SizedBox(width: 16),
                              SizedBox(width: 200, child: deleteButton),
                            ],
                          )
                              : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  editButton,
                                  const SizedBox(width: 16),
                                  changePasswordButton,
                                ],
                              ),
                              const SizedBox(height: 12),
                              deleteButton,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
