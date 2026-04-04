import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    required this.label,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
