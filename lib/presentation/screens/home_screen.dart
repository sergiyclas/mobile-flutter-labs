import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/presentation/providers/network_provider.dart';
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
    // Слухаємо стан мережі
    final isConnected = context.watch<NetworkProvider>().isConnected;

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
                  'Немає з\'єднання з Інтернетом. Працюємо в офлайн-режимі',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            // Розтягуємо сторінку на весь вільний простір, що залишився
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}