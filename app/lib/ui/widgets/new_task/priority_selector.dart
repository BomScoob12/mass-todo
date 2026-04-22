import 'package:flutter/material.dart';
import 'package:masstodo/ui/app_theme.dart';
import 'package:masstodo/ui/app_styles.dart';

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
    final priorityColors = Theme.of(context).extension<AppPriorityColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusPill,
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
              bgColor = priorityColors.low;
              boxShadow = [
                BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ];
            } else if (p == 'Medium') {
              bgColor = priorityColors.medium;
              boxShadow = [
                BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ];
            } else if (p == 'High') {
              bgColor = priorityColors.high;
              boxShadow = [
                BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ];
            }
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.radiusXL,
                  boxShadow: boxShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 18, color: textColor),
                    const SizedBox(width: AppSpacing.xs),
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
