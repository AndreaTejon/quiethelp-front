import 'package:flutter/material.dart';

class TokenInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const TokenInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(
        hintText: 'Ingresa tu token',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}