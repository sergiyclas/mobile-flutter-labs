import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider extends ChangeNotifier {
  bool _isConnected = true; // За замовчуванням вважаємо, що інтернет є
  bool get isConnected => _isConnected;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkProvider() {
    _checkInitialConnection();
    // Підписуємося на Stream (потік) змін стану мережі
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus
      );
  }

  // Перевірка при старті додатку
  Future<void> _checkInitialConnection() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  // Обробка результатів
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Якщо в списку є хоча б одне підключення, 
    // яке НЕ дорівнює .none, значить інтернет є
    final isOnline = results.any((result) => result != ConnectivityResult.none);
    
    if (_isConnected != isOnline) {
      _isConnected = isOnline;
      notifyListeners(); // Повідомляємо UI про зміну
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); 
    // Обов'язково закриваємо підписку, щоб не було витоку пам'яті
    super.dispose();
  }
}
