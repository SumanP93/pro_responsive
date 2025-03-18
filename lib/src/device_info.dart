import 'package:flutter/material.dart';

import 'screen_type.dart';

class DeviceInfo {
  final ScreenType screenType;
  final Orientation orientation;
  final Size screenSize;
  final double width;
  final double height;

  const DeviceInfo({
    required this.screenType,
    required this.orientation,
    required this.screenSize,
    required this.width,
    required this.height,
  });

  factory DeviceInfo.fromSize(Size size) {
    final width = size.width;
    final height = size.height;
    final orientation = width > height ? Orientation.landscape : Orientation.portrait;

    final screenType = _getScreenType(width, orientation);

    return DeviceInfo(screenType: screenType, orientation: orientation, screenSize: size, width: width, height: height);
  }

  static ScreenType _getScreenType(double width, Orientation orientation) {
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 900) {
      return ScreenType.tablet;
    } else if (width < 1200) {
      return ScreenType.desktop;
    } else {
      return ScreenType.tv;
    }
  }

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
  bool get isTV => screenType == ScreenType.tv;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  @override
  String toString() {
    return 'DeviceInfo(type: $screenType, orientation: $orientation, size: $screenSize)';
  }
}
