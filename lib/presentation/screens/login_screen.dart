import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_guard/presentation/providers/auth_provider.dart';
import 'package:workspace_guard/presentation/providers/network_provider.dart';
import 'package:workspace_guard/presentation/providers/workspace_state.dart';
import 'package:workspace_guard/presentation/screens/home_screen.dart';
import 'package:workspace_guard/presentation/screens/register_screen.dart';
import 'package:workspace_guard/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {

      final networkProvider = context.read<NetworkProvider>();
      if (!networkProvider.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Немає підключення до Інтернету!'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Зупиняємо виконання функції, логін не йде далі
      }

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.login(email, password);

      if (!mounted) return;

      if (success) {
        context.read<WorkspaceState>().resetData();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Помилка входу'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.blueGrey),
                const SizedBox(height: 24),
                const Text(
                  'Workspace Monitor',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть електронну пошту';
                    }
                    if (!value.contains('@')) {
                      return 'Невірний формат пошти';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Password',
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введіть пароль';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
