import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

/// A container that adjusts its maximum width based on the device type.
class ResponsiveContainer extends StatelessWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// The maximum width for mobile screens.
  final double? mobileWidth;

  /// The maximum width for tablet screens.
  final double? tabletWidth;

  /// The maximum width for desktop screens.
  final double? desktopWidth;

  /// The maximum width for TV screens.
  final double? tvWidth;

  /// The padding to apply inside the container.
  final EdgeInsetsGeometry? padding;

  /// The alignment of the child within the container.
  final AlignmentGeometry alignment;

  /// The decoration to paint behind the child.
  final BoxDecoration? decoration;

  /// The margin to apply around the container.
  final EdgeInsetsGeometry? margin;

  /// The constraints to apply to the container.
  final BoxConstraints? constraints;

  /// The clip behavior to use when painting the container.
  final Clip clipBehavior;

  /// The color to paint behind the child.
  final Color? color;

  /// The decoration to paint in front of the child.
  final Decoration? foregroundDecoration;

  /// The transform to apply before painting the child.
  final Matrix4? transform;

  /// The alignment to use when applying the transform.
  final AlignmentGeometry? transformAlignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth = double.infinity,
    this.tabletWidth,
    this.desktopWidth,
    this.tvWidth,
    this.padding,
    this.alignment = Alignment.center,
    this.decoration,
    this.margin,
    this.constraints,
    this.clipBehavior = Clip.none,
    this.color,
    this.foregroundDecoration,
    this.transform,
    this.transformAlignment,
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
          child: Container(
            constraints: constraints ?? BoxConstraints(maxWidth: maxWidth),
            padding: padding,
            margin: margin,
            decoration: decoration,
            clipBehavior: clipBehavior,
            color: color,
            foregroundDecoration: foregroundDecoration,
            transform: transform,
            transformAlignment: transformAlignment,
            child: child,
          ),
        );
      },
    );
  }
}
