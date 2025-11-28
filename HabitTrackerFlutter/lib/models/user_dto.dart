class UserDto{
  final String id;
  final String username;
  final String phoneNumber;
  final String email;

  UserDto(this.id, this.username, this.phoneNumber, this.email);

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(json['id'], json['username'], json['phoneNumber'], json['email']);
  }
}