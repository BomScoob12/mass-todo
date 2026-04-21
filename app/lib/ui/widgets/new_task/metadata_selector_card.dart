import 'package:flutter/material.dart';

class MetadataSelectorCard extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final String valueText;
  final IconData iconView;
  final Color iconBackgroundColor;
  final Color iconColor;
  final bool hasTrailingIcon;

  const MetadataSelectorCard({
    super.key,
    required this.onTap,
    required this.label,
    required this.valueText,
    required this.iconView,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.hasTrailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconView, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    valueText,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (hasTrailingIcon)
                  Icon(Icons.unfold_more, size: 20, color: Theme.of(context).colorScheme.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
