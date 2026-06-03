import 'package:flutter/material.dart';

class TokenInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  static const teal = Color(0xFF2CB9B2);

  const TokenInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: 'Ingresa tu token',
        hintStyle: TextStyle(
          color: Colors.black.withValues(alpha: 0.25),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.vpn_key_outlined,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: teal,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}