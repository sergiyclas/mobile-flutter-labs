class UserEntity {
  final String uid; // Додано
  final String username;
  final String email;
  final String password;

  const UserEntity({
    required this.uid,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'email': email,
    'password': password,
  };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    uid: json['uid'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
  );
}
