import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class MessageCard extends StatelessWidget {
  final String category;
  final bool urgent;
  final String body;
  final String received;
  final VoidCallback onReview;
  final bool unread;
  final String statusLabel;

  const MessageCard({
    super.key,
    required this.category,
    required this.urgent,
    required this.body,
    required this.received,
    required this.onReview,
    this.unread = false,
    this.statusLabel = 'Pendiente',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread
            ? const Color(0xFFD8DEE0)
            : Colors.white,
        borderRadius: AppBorders.circular18,
        border: Border.all(
          color: unread
              ? const Color(0xFFB8C4C7)
              : Colors.black.withOpacity(0.06),
          width: unread ? 1.4 : 1,
        ),
        boxShadow: [AppShadows.small],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (unread) const _UnreadDot(),
              _CategoryTag(category),
              if (urgent) const _UrgentTag(),
              _StatusTag(statusLabel),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight:
                  unread ? FontWeight.w800 : FontWeight.w600,
              color: Colors.black.withOpacity(0.72),
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
                    color: Colors.black.withOpacity(0.38),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: onReview,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.circular999,
                  ),
                  side: BorderSide(
                    color: unread
                        ? const Color(0xFFB8C4C7)
                        : Colors.black12,
                  ),
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

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 2),
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
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String text;

  const _CategoryTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: AppBorders.circular999,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _UrgentTag extends StatelessWidget {
  const _UrgentTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
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
  final String text;

  const _StatusTag(this.text);

  @override
  Widget build(BuildContext context) {
    final isReview = text == 'En revisión';
    final isSolved = text == 'Resuelto';

    final bg = isReview
        ? const Color(0xFFE3F2FD)
        : isSolved
            ? const Color(0xFFE8F5E9)
            : AppColors.softOrange;

    final fg = isReview
        ? const Color(0xFF0C6F8A)
        : isSolved
            ? const Color(0xFF2E7D32)
            : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppBorders.circular999,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}