import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.cursorColor,
    this.onTap,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
