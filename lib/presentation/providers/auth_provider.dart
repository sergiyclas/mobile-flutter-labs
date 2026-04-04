import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_guard/data/api/api_client.dart';
import 'package:workspace_guard/data/repositories/auth_repository.dart';
import 'package:workspace_guard/domain/entities/user_entity.dart';
import 'package:workspace_guard/domain/repositories/i_user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IUserRepository _userRepository;
  late final AuthRepository _authRepository;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._userRepository) {
    _authRepository = AuthRepository(ApiClient());
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
      final response = await _authRepository.signIn(email, password);
      
      final token = response['idToken'] as String;
      final uid = response['localId'] as String; // Отримуємо унікальний ID юзера

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      final user = UserEntity(
        uid: uid, // Зберігаємо ID
        username: 'User', 
        email: email, 
        password: password,
      );
      
      await _userRepository.registerUser(user);
      await _userRepository.loginUser(email, password);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Невірний email або пароль (або акаунта не існує)';
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
      final response = await _authRepository.signUp(email, password);
      final uid = response['localId'] as String; // Отримуємо UID при реєстрації

      final user = UserEntity(
        uid: uid, // Зберігаємо ID
        username: username, 
        email: email, 
        password: password,
      );
      
      await _userRepository.registerUser(user);
      
      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      _errorMessage = 'Помилка: Можливо такий email вже зареєстрований';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); 
    
    await _userRepository.logoutUser();
    _currentUser = null;
    notifyListeners();
  }
}
