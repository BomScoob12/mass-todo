import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool isTitle;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.isTitle = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: isTitle
          ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
          : Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: isTitle
            ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  fontWeight: FontWeight.w500,
                )
            : Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: isTitle ? 24 : 20,
        ),
      ),
      validator: validator,
    );
  }
}
