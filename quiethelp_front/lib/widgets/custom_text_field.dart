import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLength;
  final int? minLines;
  final int? maxLines;
  final bool isMultiline;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLength = 40,
    this.minLines,
    this.maxLines,
    this.isMultiline = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMultiline) {
      return TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        minLines: widget.minLines ?? 6,
        maxLines: widget.maxLines ?? 8,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.25),
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.12)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: AppColors.teal, width: 1.4),
          ),
        ),
      );
    }

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasFocus ? AppColors.teal : Colors.black.withOpacity(0.12),
          width: _hasFocus ? 1.4 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLength: widget.maxLength,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.35),
            ),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}