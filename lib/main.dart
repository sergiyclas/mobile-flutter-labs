import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WorkspaceState(),
      child: Consumer<WorkspaceState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Workspace Monitor',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueGrey,
                brightness:
                    appState.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

class WorkspaceState extends ChangeNotifier {
  int distance = 45;
  bool hasMotion = false;

  List<int> distanceHistory = <int>[...List.filled(12, 45)];
  List<int> motionHistory = <int>[...List.filled(12, 0)];

  List<String> history = ['System initialized'];
  Timer? _timer;
  bool isSimulationRunning = true;
  bool isDarkMode = true;
  bool notificationsEnabled = true;

  WorkspaceState() {
    _startSimulation();
  }

  void toggleSimulation() {
    isSimulationRunning = !isSimulationRunning;
    if (isSimulationRunning) {
      _startSimulation();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  void toggleTheme(bool value) {
    isDarkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void _startSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();

      distance = 30 + random.nextInt(40);
      hasMotion = random.nextDouble() > 0.7;

      distanceHistory.add(distance);
      if (distanceHistory.length > 12) distanceHistory.removeAt(0);

      motionHistory.add(hasMotion ? 1 : 0);
      if (motionHistory.length > 12) motionHistory.removeAt(0);

      if (distance < 40) _addLog('Too close to the screen: $distance cm!');
      if (hasMotion) _addLog('Motion detected at the door!');

      notifyListeners();
    });
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}'
        ':${now.second.toString().padLeft(2, '0')}';

    history.insert(0, '$time - $message');
    if (history.length > 20) history.removeLast();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
