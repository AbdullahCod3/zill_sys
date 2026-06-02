import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// A frosted overlay pill (`.home-callout` / `.cust-hint`): translucent surface,
/// blur, hairline border. Used for floating callouts and hints.
class GlassPill extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final bool dashedBorder;

  const GlassPill({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    this.dashedBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors.bgOverlay,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}
