import 'screen_type.dart';

class ResponsiveConstraints {
  static const double mobileMaxWidth = 599;
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 899;
  static const double desktopMinWidth = 900;
  static const double desktopMaxWidth = 1199;
  static const double tvMinWidth = 1200;

  static const double portraitMaxRatio = 1.0;

  static const Map<ScreenType, List<double>> screenBoundaries = {
    ScreenType.mobile: [0, mobileMaxWidth],
    ScreenType.tablet: [tabletMinWidth, tabletMaxWidth],
    ScreenType.desktop: [desktopMinWidth, desktopMaxWidth],
    ScreenType.tv: [tvMinWidth, double.infinity],
  };
}
