import 'package:flutter/material.dart';

import 'device_info.dart';

/// A widget that builds different layouts based on device type and orientation.
class ResponsiveBuilder extends StatelessWidget {
  /// The general builder function that provides device information.
  final Widget Function(BuildContext context, DeviceInfo deviceInfo) builder;

  /// Optional builders for specific device types and orientations.
  final Widget? mobileBuilder;
  final Widget? tabletBuilder;
  final Widget? desktopBuilder;
  final Widget? tvBuilder;
  final Widget? portraitBuilder;
  final Widget? landscapeBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.tvBuilder,
    this.portraitBuilder,
    this.landscapeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceInfo = DeviceInfo.fromSize(Size(constraints.maxWidth, constraints.maxHeight));

        // Check for specific device type builders
        if (deviceInfo.isMobile && mobileBuilder != null) {
          return mobileBuilder!;
        }
        if (deviceInfo.isTablet && tabletBuilder != null) {
          return tabletBuilder!;
        }
        if (deviceInfo.isDesktop && desktopBuilder != null) {
          return desktopBuilder!;
        }
        if (deviceInfo.isTV && tvBuilder != null) {
          return tvBuilder!;
        }

        // Check for orientation-specific builders
        if (deviceInfo.isPortrait && portraitBuilder != null) {
          return portraitBuilder!;
        }
        if (deviceInfo.isLandscape && landscapeBuilder != null) {
          return landscapeBuilder!;
        }

        // Use the general builder as a fallback
        return builder(context, deviceInfo);
      },
    );
  }
}
