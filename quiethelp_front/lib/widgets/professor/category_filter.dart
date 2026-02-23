import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class CategoryFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CategoryFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> _categories = [
    'Todos',
    'Bullying',
    'Académico',
    'Emocional',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 10),
          ..._categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  text: category,
                  selected: value == category,
                  onTap: () => onChanged(category),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : Colors.white,
          borderRadius: AppBorders.circular999,
          border: Border.all(color: AppColors.teal),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.teal,
          ),
        ),
      ),
    );
  }
}