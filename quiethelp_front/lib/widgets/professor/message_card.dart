import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class MessageCard extends StatelessWidget {
  final String category;
  final bool urgent;
  final String body;
  final String received;
  final VoidCallback onReview;

  const MessageCard({
    super.key,
    required this.category,
    required this.urgent,
    required this.body,
    required this.received,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorders.circular18,
        border: AppBorders.lightBorder,  // 👌 AHORA FUNCIONA
        boxShadow: [AppShadows.small],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryTag(category),
              if (urgent) const _UrgentTag(),
              const _StatusTag(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  received,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onReview,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.circular999,
                  ),
                  side: const BorderSide(color: Colors.black12), // 👈 Cambiado temporalmente
                ),
                child: const Text(
                  'Revisar',
                  style: AppTextStyles.labelMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String text;
  const _CategoryTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: AppBorders.circular999,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _UrgentTag extends StatelessWidget {
  const _UrgentTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softRed,
        borderRadius: AppBorders.circular999,
      ),
      child: Text(
        'Urgente',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.errorRed,
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softOrange,
        borderRadius: AppBorders.circular999,
      ),
      child: Text(
        'Pendiente',
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.warningOrange,
        ),
      ),
    );
  }
}