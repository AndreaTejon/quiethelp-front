import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class StatusTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const StatusTabs({
    super.key,
    required this.index,
    required this.onChanged,
  });

  static const List<String> _tabs = ['Pendientes', 'En revisión', 'Resueltos'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorders.circular999,
      ),
      child: Row(
        children: List.generate(
          _tabs.length,
          (i) => Expanded(
            child: _StatusTab(
              text: _tabs[i],
              selected: index == i,
              onTap: () => onChanged(i),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _StatusTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.circular999,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.black.withOpacity(0.06) : Colors.transparent,
          borderRadius: AppBorders.circular999,
        ),
        child: Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.black.withOpacity(selected ? 0.8 : 0.55),
          ),
        ),
      ),
    );
  }
}