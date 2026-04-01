import 'package:flutter/material.dart';
import 'package:workspace_guard/domain/entities/user_entity.dart';
import 'package:workspace_guard/domain/repositories/i_user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IUserRepository _userRepository;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._userRepository) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _currentUser = await _userRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.loginUser(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Невірний email або пароль';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Помилка авторизації: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = UserEntity(
        username: username,
        email: email,
        password: password,
      );
      // Зберігаємо в локальне сховище
      await _userRepository.registerUser(user);
      _isLoading = false;
      notifyListeners();
      return true; // Успіх
    } catch (e) {
      _errorMessage = 'Помилка реєстрації: $e';
      _isLoading = false;
      notifyListeners();
      return false; // Провал
    }
  }

  Future<void> logout() async {
    await _userRepository.logoutUser();
    _currentUser = null;
    notifyListeners();
  }
}
