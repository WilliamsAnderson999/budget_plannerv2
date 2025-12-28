import 'package:flutter/material.dart';
import 'package:budget_manager/theme/auth_palette.dart';

class PillChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool selected;

  const PillChip({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : AuthPalette.cloud.withOpacity(0.55);
    final fg = selected ? AuthPalette.ink : AuthPalette.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AuthPalette.cloud.withOpacity(0.55),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
