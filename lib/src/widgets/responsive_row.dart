import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../responsive_extensions.dart';
import '../screen_type.dart';

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool expandChildren;
  final EdgeInsetsGeometry? padding;

  // This helps control how widgets wrap based on screen size
  final Map<ScreenType, int> breakpoints;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.expandChildren = false,
    this.padding,
    this.breakpoints = const {ScreenType.mobile: 1, ScreenType.tablet: 2, ScreenType.desktop: 4, ScreenType.tv: 6},
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceInfo) {
        final itemsPerRow =
            breakpoints[deviceInfo.screenType] ??
            (deviceInfo.isMobile
                ? 1
                : deviceInfo.isTablet
                ? 2
                : deviceInfo.isDesktop
                ? 4
                : 6);

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Wrap(alignment: WrapAlignment.start, children: _buildWrappedChildren(context, itemsPerRow)),
        );
      },
    );
  }

  List<Widget> _buildWrappedChildren(BuildContext context, int itemsPerRow) {
    final List<Widget> wrappedChildren = [];
    final double itemWidth = 1 / itemsPerRow;

    for (var child in children) {
      wrappedChildren.add(
        SizedBox(width: context.widthPercent(itemWidth), child: expandChildren ? Expanded(child: child) : child),
      );
    }

    return wrappedChildren;
  }
}
