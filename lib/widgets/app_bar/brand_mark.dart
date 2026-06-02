import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Z-glyph brand mark that doubles as a shadow projection (from `app.jsx`).
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 32});

  static const _svg = '''
<svg viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="zgrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#7C6FF7"/>
      <stop offset="100%" stop-color="#5EEAD4"/>
    </linearGradient>
  </defs>
  <path d="M 6 6 H 26 L 8 26 H 26" stroke="url(#zgrad)" stroke-width="2.5" stroke-linecap="square" stroke-linejoin="miter" fill="none"/>
  <path d="M 10 10 H 26 L 12 26 H 26" stroke="#7C6FF7" stroke-opacity="0.25" stroke-width="1" fill="none"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.string(_svg, fit: BoxFit.contain),
    );
  }
}
