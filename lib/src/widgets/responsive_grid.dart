import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final Map<ScreenType, int> columnCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columnCount = const {ScreenType.mobile: 1, ScreenType.tablet: 2, ScreenType.desktop: 4, ScreenType.tv: 6},
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceInfo) {
        final columns =
            columnCount[deviceInfo.screenType] ??
            (deviceInfo.isMobile
                ? 1
                : deviceInfo.isTablet
                ? 2
                : deviceInfo.isDesktop
                ? 4
                : 6);

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          ),
        );
      },
    );
  }
}
