class LoginRequestDto {
  String email;
  String password;

  LoginRequestDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Email': email,
      'Password': password,
    };
    return data;
  }
}