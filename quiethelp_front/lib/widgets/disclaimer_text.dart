import 'package:flutter/material.dart';

class DisclaimerText extends StatelessWidget {
  final String text;

  const DisclaimerText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: Colors.black.withOpacity(0.35),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}