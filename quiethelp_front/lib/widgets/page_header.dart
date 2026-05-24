import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? logoSize;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/images/quiethelp_logo.svg',
          width: logoSize ?? 92,
          height: logoSize ?? 92,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 22),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.25,
            color: Colors.black.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}