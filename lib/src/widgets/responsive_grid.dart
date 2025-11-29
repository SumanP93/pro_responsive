import 'package:flutter/material.dart';

import '../responsive_builder.dart';
import '../screen_type.dart';

/// Enum to specify which grid delegate to use
enum GridDelegateType {
  /// Use SliverGridDelegateWithFixedCrossAxisCount
  fixedCrossAxisCount,

  /// Use SliverGridDelegateWithMaxCrossAxisExtent
  maxCrossAxisExtent,
}

/// A grid that adjusts the number of columns based on the device type.
///
/// This widget is optimized for both small and large datasets:
/// - For small lists, use the [children] parameter with [shrinkWrap] = true
/// - For large datasets, use [itemCount] and [itemBuilder] for lazy loading
/// - Supports both FixedCrossAxisCount and MaxCrossAxisExtent delegates
class ResponsiveGrid extends StatelessWidget {
  /// The list of child widgets to display in the grid.
  /// Only use this for small lists. For large datasets, use [itemBuilder].
  final List<Widget>? children;

  /// The number of items in the grid (required when using [itemBuilder]).
  final int? itemCount;

  /// Builder function for creating grid items on demand (efficient for large lists).
  final IndexedWidgetBuilder? itemBuilder;

  /// The number of columns for each screen type.
  /// Only applicable when [delegateType] is [GridDelegateType.fixedCrossAxisCount].
  final Map<ScreenType, int> columnCount;

  /// The maximum extent for each tile.
  /// Only applicable when [delegateType] is [GridDelegateType.maxCrossAxisExtent].
  final Map<ScreenType, double>? maxCrossAxisExtent;

  /// The type of grid delegate to use.
  final GridDelegateType delegateType;

  /// The spacing between grid items.
  final double spacing;

  /// The spacing between rows in the grid.
  final double runSpacing;

  /// The padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Whether to shrink-wrap the grid (set to false for large lists).
  final bool shrinkWrap;

  /// The scroll physics for the grid.
  final ScrollPhysics? physics;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The main axis spacing multiplied by this factor when determining the cell size.
  final double? mainAxisExtent;

  /// Creates a responsive grid with a fixed list of children.
  /// This is suitable for small lists but inefficient for large datasets.
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columnCount = const {ScreenType.mobile: 1, ScreenType.tablet: 2, ScreenType.desktop: 4, ScreenType.tv: 6},
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  }) : itemCount = null,
       itemBuilder = null,
       maxCrossAxisExtent = null,
       delegateType = GridDelegateType.fixedCrossAxisCount;

  /// Creates an efficient responsive grid with a builder function.
  /// This is optimized for large datasets as it builds items lazily.
  const ResponsiveGrid.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.columnCount = const {ScreenType.mobile: 1, ScreenType.tablet: 2, ScreenType.desktop: 4, ScreenType.tv: 6},
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  }) : children = null,
       maxCrossAxisExtent = null,
       delegateType = GridDelegateType.fixedCrossAxisCount;

  /// Creates an efficient responsive grid with MaxCrossAxisExtent delegate.
  /// This allows tiles to have a maximum size, with the grid fitting as many as possible.
  const ResponsiveGrid.extent({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.maxCrossAxisExtent,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  }) : children = null,
       columnCount = const {},
       delegateType = GridDelegateType.maxCrossAxisExtent;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceInfo) {
        // Determine the grid delegate based on the type
        SliverGridDelegate gridDelegate;

        if (delegateType == GridDelegateType.maxCrossAxisExtent) {
          final extent =
              maxCrossAxisExtent?[deviceInfo.screenType] ??
              (deviceInfo.isMobile
                  ? 150.0
                  : deviceInfo.isTablet
                  ? 200.0
                  : deviceInfo.isDesktop
                  ? 250.0
                  : 300.0);

          gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: extent,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
            mainAxisExtent: mainAxisExtent,
          );
        } else {
          final columns =
              columnCount[deviceInfo.screenType] ??
              (deviceInfo.isMobile
                  ? 1
                  : deviceInfo.isTablet
                  ? 2
                  : deviceInfo.isDesktop
                  ? 4
                  : 6);

          gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
            mainAxisExtent: mainAxisExtent,
          );
        }

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: shrinkWrap,
            physics: physics,
            gridDelegate: gridDelegate,
            itemCount: itemCount ?? children?.length ?? 0,
            itemBuilder:
                itemBuilder ??
                (context, index) {
                  return children![index];
                },
          ),
        );
      },
    );
  }
}
