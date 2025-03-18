import 'package:flutter/material.dart';

import 'device_info.dart';
import 'screen_type.dart';

extension ResponsiveExtensions on BuildContext {
  DeviceInfo get deviceInfo {
    final mediaQuery = MediaQuery.of(this);
    return DeviceInfo.fromSize(mediaQuery.size);
  }

  bool get isMobile => deviceInfo.isMobile;
  bool get isTablet => deviceInfo.isTablet;
  bool get isDesktop => deviceInfo.isDesktop;
  bool get isTV => deviceInfo.isTV;
  bool get isPortrait => deviceInfo.isPortrait;
  bool get isLandscape => deviceInfo.isLandscape;

  double get screenWidth => deviceInfo.width;
  double get screenHeight => deviceInfo.height;

  double widthPercent(double percent) => deviceInfo.width * percent;
  double heightPercent(double percent) => deviceInfo.height * percent;

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
      default:
        return mobile;
    }
  }
}
