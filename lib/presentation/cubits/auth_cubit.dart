import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_guard/data/repositories/auth_repository.dart';
import 'package:workspace_guard/domain/entities/user_entity.dart';
import 'package:workspace_guard/domain/repositories/i_user_repository.dart';

// 1. ОПИСУЄМО СТАН: Все, що стосується авторизації, зберігається тут
class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  // Метод для зручного оновлення лише частини стану
  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// 2. САМ CUBIT: Логіка, яка керує станом
class AuthCubit extends Cubit<AuthState> {
  final IUserRepository _userRepository;
  final AuthRepository _authRepository;

  AuthCubit({
    required IUserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository,
        super(const AuthState()) {
    _loadUser(); // Автологін при запуску
  }

  Future<void> _loadUser() async {
    emit(state.copyWith(isLoading: true));
    final user = await _userRepository.getCurrentUser();
    emit(state.copyWith(currentUser: user, isLoading: false));
  }

  Future<bool> login(String email, String password) async {
    // Емітимо стан завантаження + очищаємо старі помилки
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _authRepository.signIn(email, password);
      final prefs = await SharedPreferences.getInstance();
      final uid = response['localId'] as String;

      await prefs.setString('auth_token', response['idToken'] as String);

      final user = UserEntity(
        username: 'User',
        email: email,
        password: password,
        uid: uid,
      );
      await _userRepository.registerUser(user);
      await _userRepository.loginUser(email, password);

      // Успіх! Емітимо новий стан з юзером
      emit(state.copyWith(currentUser: user, isLoading: false));
      return true;
    } catch (e) {
      // Помилка! Емітимо стан з помилкою
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error: Invalid email or password',
        ),
      );
      return false;
    }
  }

  Future<bool> register(String username, String email, String pass) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _authRepository.signUp(email, pass);
      final user = UserEntity(
        username: username, 
        email: email, 
        password: pass, 
        uid: '');
      await _userRepository.registerUser(user);

      emit(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error: Email might already be registered',
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await _userRepository.logoutUser();
    // Скидаємо стан до початкового (без юзера)
    emit(const AuthState());
  }
}
