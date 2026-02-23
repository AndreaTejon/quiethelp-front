import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AboutInfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const AboutInfoCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: AppBorders.circular20,
        border: AppBorders.lightBorder,
        boxShadow: [AppShadows.small],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}