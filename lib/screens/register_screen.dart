import 'package:flutter/material.dart';
import 'package:workspace_guard/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomTextField(label: 'Username'),
            const CustomTextField(label: 'Email'),
            const CustomTextField(label: 'Password', isPassword: true),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
