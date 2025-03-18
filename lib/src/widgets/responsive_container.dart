import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? tvWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth = double.infinity,
    this.tabletWidth,
    this.desktopWidth,
    this.tvWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceInfo) {
        double maxWidth;

        switch (deviceInfo.screenType) {
          case ScreenType.mobile:
            maxWidth = mobileWidth ?? double.infinity;
            break;
          case ScreenType.tablet:
            maxWidth = tabletWidth ?? mobileWidth ?? double.infinity;
            break;
          case ScreenType.desktop:
            maxWidth = desktopWidth ?? tabletWidth ?? mobileWidth ?? double.infinity;
            break;
          case ScreenType.tv:
            maxWidth = tvWidth ?? desktopWidth ?? tabletWidth ?? mobileWidth ?? double.infinity;
            break;
        }

        return Align(
          alignment: alignment,
          child: Container(constraints: BoxConstraints(maxWidth: maxWidth), padding: padding, child: child),
        );
      },
    );
  }
}
