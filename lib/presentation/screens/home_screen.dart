import 'package:flutter/material.dart';
import 'package:workspace_guard/presentation/screens/dashboard_screen.dart';
import 'package:workspace_guard/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
      case 0:
        page = const DashboardScreen();
        break;
      case 1:
        page = const ProfileScreen();
        break;
      default:
        throw UnimplementedError('No widget for $_selectedIndex');
    }

    return Scaffold(
      body: SafeArea(child: page),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) => setState(() => _selectedIndex = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
