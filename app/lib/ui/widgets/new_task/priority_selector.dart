import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String currentPriority;
  final ValueChanged<String> onChanged;

  const PrioritySelector({
    super.key,
    required this.currentPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['Low', 'Medium', 'High'].map((p) {
          final isSelected = currentPriority == p;

          Color bgColor = Colors.transparent;
          Color textColor = Theme.of(context).colorScheme.onSurfaceVariant;
          IconData iconData = Icons.horizontal_rule;
          List<BoxShadow> boxShadow = [];

          if (p == 'Low') iconData = Icons.keyboard_arrow_down;
          if (p == 'High') iconData = Icons.keyboard_arrow_up;

          if (isSelected) {
            textColor = Colors.white;
            if (p == 'Low') {
              bgColor = Colors.grey.shade600;
              boxShadow = [BoxShadow(color: Colors.grey.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))];
            } else if (p == 'Medium') {
              bgColor = Colors.orange.shade600;
              boxShadow = [BoxShadow(color: Colors.orange.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))];
            } else if (p == 'High') {
              bgColor = Colors.red.shade600;
              boxShadow = [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))];
            }
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: boxShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 18, color: textColor),
                    const SizedBox(width: 6),
                    Text(
                      p,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
