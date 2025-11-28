import 'package:habit_tracker_mobile/models/user_dto.dart';
import 'package:habit_tracker_mobile/services/user_service.dart';

class UserSessionService {
  static final UserSessionService _instance = UserSessionService._internal();
  factory UserSessionService() => _instance;
  UserSessionService._internal();

  UserDto? _currentUser;
  final UserService _userService = UserService();

  UserDto? get currentUser => _currentUser;

  void setUser(UserDto user) {
    _currentUser = user;
  }

  void clearUser() {
    _currentUser = null;
  }

  Future<UserDto?> getUser() async {
    final response = await _userService.getUserAsync();
    if (response.isSuccess && response.data != null) {
      _currentUser = response.data!;
      return _currentUser;
    } else {
      return null;
    }
  }


  bool get isUserLoaded => _currentUser != null;
}
