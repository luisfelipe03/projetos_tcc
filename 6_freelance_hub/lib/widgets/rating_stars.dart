import 'package:flutter/material.dart';

const _amber = Color(0xFFFFB300);

/// N estrelas (default 5). Mostra `value` cheias e o resto outlined.
/// Versão `interactive` (default false): tap em uma estrela chama [onChanged]
/// com 1-based index. Versão read-only ignora taps.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.max = 5,
    this.size = 22,
    this.interactive = false,
    this.onChanged,
    this.activeColor = _amber,
    this.inactiveColor,
  });

  final int value;
  final int max;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onChanged;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final inactive = inactiveColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.25));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < value;
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? activeColor : inactive,
        );
        if (!interactive) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: icon,
          );
        }
        return GestureDetector(
          onTap: () => onChanged?.call(i + 1),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: icon,
          ),
        );
      }),
    );
  }
}
