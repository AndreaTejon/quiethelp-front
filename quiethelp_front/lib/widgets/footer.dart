import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppFooter extends StatelessWidget {
  final VoidCallback onAbout;

  const AppFooter({super.key, required this.onAbout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'QuietHelp',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Un espacio seguro para estudiantes',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black.withOpacity(0.45),
          ),
        ),
        const SizedBox(height: 6),
        MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: onAbout,
    child: const Text(
      '¿Quiénes somos?',
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: AppColors.teal,
      ),
    ),
  ),
)
      ],
    );
  }
}