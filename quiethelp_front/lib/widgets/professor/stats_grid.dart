import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class StatsGrid extends StatelessWidget {
  final ValueChanged<int> onTap;

  const StatsGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Pendientes', value: '2', icon: Icons.inbox_outlined, onTap: () => onTap(0))),
            const SizedBox(width: 16),
            Expanded(child: _StatBox(label: 'En revisión', value: '1', icon: Icons.access_time, onTap: () => onTap(1))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Resueltos', value: '1', icon: Icons.check_box_outlined, onTap: () => onTap(2))),
            const SizedBox(width: 16),
            Expanded(child: _StatBox(label: 'Urgentes', value: '1', icon: Icons.warning_amber_rounded, onTap: () => onTap(0))),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label; final String value; final IconData icon; final VoidCallback onTap;
  const _StatBox({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.circular18,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppBorders.circular18,
          border: Border.all(color: Colors.black.withOpacity(0.08)), // 👈 Cambiado directamente
          boxShadow: [AppShadows.card],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black.withOpacity(0.6)),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium.copyWith(color: Colors.black.withOpacity(0.6))),
                const SizedBox(height: 6),
                Text(value, style: AppTextStyles.titleLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}