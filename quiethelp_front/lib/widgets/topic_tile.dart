import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TopicTile extends StatelessWidget {
  final double width;
  final double height;
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const TopicTile({
    super.key,
    required this.width,
    required this.height,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected 
                ? AppColors.teal.withOpacity(0.65)
                : Colors.black.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.teal : Colors.black.withOpacity(0.65),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.2,
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}