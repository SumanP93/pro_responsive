import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

/// A text widget that adjusts its font size based on the device type.
class ResponsiveText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The font size for mobile screens.
  final double mobileFontSize;

  /// The font size for tablet screens.
  final double? tabletFontSize;

  /// The font size for desktop screens.
  final double? desktopFontSize;

  /// The font size for TV screens.
  final double? tvFontSize;

  /// The style to apply to the text.
  final TextStyle? style;

  /// The alignment of the text.
  final TextAlign? textAlign;

  /// The maximum number of lines for the text.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.tvFontSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceInfo) {
        double fontSize;

        switch (deviceInfo.screenType) {
          case ScreenType.mobile:
            fontSize = mobileFontSize;
            break;
          case ScreenType.tablet:
            fontSize = tabletFontSize ?? mobileFontSize * 1.2;
            break;
          case ScreenType.desktop:
            fontSize = desktopFontSize ?? tabletFontSize ?? mobileFontSize * 1.4;
            break;
          case ScreenType.tv:
            fontSize = tvFontSize ?? desktopFontSize ?? tabletFontSize ?? mobileFontSize * 1.6;
            break;
        }

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
