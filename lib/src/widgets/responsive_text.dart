import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final double mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final double? tvFontSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
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
