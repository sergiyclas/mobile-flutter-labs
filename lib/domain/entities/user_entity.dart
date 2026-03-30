class UserEntity {
  final String username;
  final String email;
  final String password;

  const UserEntity({
    required this.username,
    required this.email,
    required this.password,
  });

  // Перетворюємо об'єкт у Map для збереження в JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  // Створюємо об'єкт з Map після зчитування з локального сховища
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}
