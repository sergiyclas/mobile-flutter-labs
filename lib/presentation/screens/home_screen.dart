import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/presentation/providers/auth_provider.dart';
import 'package:workspace_guard/presentation/providers/network_provider.dart';
import 'package:workspace_guard/presentation/providers/workspace_state.dart';
import 'package:workspace_guard/presentation/screens/dashboard_screen.dart';
import 'package:workspace_guard/presentation/screens/logs_screen.dart';
import 'package:workspace_guard/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
// Як тільки екран завантажився, беремо UID юзера і передаємо в WorkspaceState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      context.read<WorkspaceState>().setUserId(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Слухаємо стан мережі
    final isConnected = context.watch<NetworkProvider>().isConnected;

    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const LogsScreen(); // Додали наш новий екран логів!
        break;
      case 2:
        page = const ProfileScreen();
        break;
      default:
        throw UnimplementedError('No widget for $_selectedIndex');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Якщо інтернету немає, показуємо цей червоний банер
            if (!isConnected)
              Container(
                width: double.infinity,
                color: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  'No Internet Connection! Working in offline mode.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            // Розтягуємо сторінку на весь вільний простір
            Expanded(child: page),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() => _selectedIndex = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // Нова іконка для логів
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
