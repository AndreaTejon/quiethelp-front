import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

enum MenuOption { about, logout }

class MenuPopup extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onAbout;

  const MenuPopup({super.key, this.onLogout, this.onAbout});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuOption>(
        tooltip: '',
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      offset: const Offset(0, 52),
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.12),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.circular14,
        side: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      constraints: const BoxConstraints(minWidth: 220),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: MenuOption.about,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.black.withOpacity(0.70)),
              const SizedBox(width: 10),
              Text('¿Quiénes somos?', style: AppTextStyles.labelMedium.copyWith(color: Colors.black.withOpacity(0.85))),
            ],
          ),
        ),
        PopupMenuItem(
          value: MenuOption.logout,
          height: 44,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.black.withOpacity(0.70)),
              const SizedBox(width: 10),
              Text('Cerrar sesión', style: AppTextStyles.labelMedium.copyWith(color: Colors.black.withOpacity(0.85))),
            ],
          ),
        ),
      ],
      onSelected: (option) {
        switch (option) {
          case MenuOption.about:
            onAbout?.call();
            break;
          case MenuOption.logout:
            onLogout?.call();
            break;
        }
      },
    );
  }
}