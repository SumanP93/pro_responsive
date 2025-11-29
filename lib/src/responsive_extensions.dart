import 'package:flutter/material.dart';

import 'device_info.dart';
import 'screen_type.dart';

extension ResponsiveExtensions on BuildContext {
  /// Returns device information based on the current screen size.
  DeviceInfo get deviceInfo {
    final mediaQuery = MediaQuery.of(this);
    return DeviceInfo.fromSize(mediaQuery.size);
  }

  /// Screen type getters
  bool get isMobile => deviceInfo.isMobile;
  bool get isTablet => deviceInfo.isTablet;
  bool get isDesktop => deviceInfo.isDesktop;
  bool get isTV => deviceInfo.isTV;
  bool get isPortrait => deviceInfo.isPortrait;
  bool get isLandscape => deviceInfo.isLandscape;

  double get screenWidth => deviceInfo.width;
  double get screenHeight => deviceInfo.height;

  /// Returns a percentage of the screen width or height. Value between 0.0 and 1.0
  double widthPercent(double percent) => deviceInfo.width * percent;
  double heightPercent(double percent) => deviceInfo.height * percent;

  /// Returns a value based on the current screen type.
  double responsiveValue<T>({required double mobile, double? tablet, double? desktop, double? tv}) {
    final type = deviceInfo.screenType;

    switch (type) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenType.tv:
        return tv ?? desktop ?? tablet ?? mobile;
    }
  }
}
