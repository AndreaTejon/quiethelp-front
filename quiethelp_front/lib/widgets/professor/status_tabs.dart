import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class StatusTabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final bool hasUnreadInReview;

  const StatusTabs({
    super.key,
    required this.index,
    required this.onChanged,
    this.hasUnreadInReview = false,
  });

  static const List<String> _tabs = [
    'Pendientes',
    'En revisión',
    'Resueltos',
  ];

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
              showUnreadDot: i == 1 && hasUnreadInReview,
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
  final bool showUnreadDot;
  final VoidCallback onTap;

  const _StatusTab({
    required this.text,
    required this.selected,
    required this.showUnreadDot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.circular999,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? Colors.black.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: AppBorders.circular999,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.black.withOpacity(
                      selected ? 0.8 : 0.55,
                    ),
                  ),
                ),
              ),

              if (showUnreadDot)
                Positioned(
                  top: -4,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.35),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}