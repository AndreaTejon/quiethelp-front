import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ContactLine extends StatelessWidget {
  final String left;
  final String right;
  final String suffix;

  const ContactLine({
    super.key,
    required this.left,
    required this.right,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.black.withOpacity(0.55),
        ),
        children: [
          TextSpan(text: left),
          TextSpan(
            text: right,
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: suffix),
        ],
      ),
    );
  }
}