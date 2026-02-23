import 'package:flutter/material.dart';

class AppColors {
  static const Color teal = Color(0xFF2CB9B2);
  static const Color tealLight = Color(0xFFE0F2F1);
  static const Color tealSoft = Color(0xFFEFF7F6);
  static const Color bgSoft = Color(0xFFEFF7F6);
  static const Color errorRed = Color(0xFFFF5A5F);
  static const Color warningOrange = Color(0xFFE09B2D);
  static const Color softRed = Color(0xFFFFE8EA);
  static const Color softOrange = Color(0xFFFFF2DE);
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    fontFamily: fontFamily,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
  );
}

class AppShadows {
  static BoxShadow card = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 18,
    offset: const Offset(0, 10),
  );

  static BoxShadow small = BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 14,
    offset: const Offset(0, 8),
  );
}

class AppBorders {
  static BorderRadius circular8 = BorderRadius.circular(8);
  static BorderRadius circular12 = BorderRadius.circular(12);
  static BorderRadius circular14 = BorderRadius.circular(14);
  static BorderRadius circular18 = BorderRadius.circular(18);
  static BorderRadius circular20 = BorderRadius.circular(20); // 👈 AÑADIDO
  static BorderRadius circular24 = BorderRadius.circular(24);
  static BorderRadius circular32 = BorderRadius.circular(32);
  static BorderRadius circular999 = BorderRadius.circular(999);

  static BoxBorder lightBorder = Border.all(color: Colors.black.withOpacity(0.06));
  static BoxBorder mediumBorder = Border.all(color: Colors.black.withOpacity(0.12));
  static BoxBorder tealBorder = Border.all(color: AppColors.teal, width: 1.4);
}