import 'package:flutter/widgets.dart';

/// The Zill brand mark shown in the app bar. Reads from
/// `assets/images/zill_logo.png` so the visual identity is editable without
/// touching code.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/zill_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}
