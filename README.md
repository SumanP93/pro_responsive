# pro_responsive

A comprehensive Flutter responsive design package that automatically adapts your UI across **Mobile**, **Tablet**, **Desktop**, and **TV** screens — with zero platform-specific code.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [How It Works — Core Concepts](#how-it-works--core-concepts)
  - [Screen Type Detection](#1-screen-type-detection)
  - [DeviceInfo Object](#2-deviceinfo-object)
- [Widgets & APIs](#widgets--apis)
  - [ResponsiveBuilder](#responsivebuilder)
  - [ResponsiveText](#responsivetext)
  - [ResponsiveGrid](#responsivegrid)
  - [ResponsiveList](#responsivelist)
  - [ResponsiveContainer](#responsivecontainer)
  - [ResponsiveRow](#responsiverow)
- [Context Extensions](#context-extensions)
- [Step-by-Step Usage Guide](#step-by-step-usage-guide)
- [Complete Example](#complete-example)
- [API Reference](#api-reference)

---

## Overview

`pro_responsive` solves the common Flutter problem of building a **single codebase** that looks great on all screen sizes. Instead of writing messy `MediaQuery` checks everywhere, this package gives you:

- A clean `ResponsiveBuilder` widget with per-device builders
- Automatic font scaling with `ResponsiveText`
- Efficient lazy-loaded grids and lists that re-column automatically
- `BuildContext` extensions to query screen info anywhere
- A `ResponsiveConstraints` class with consistent width breakpoints

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  pro_responsive: ^0.0.1
```

Then run:

```bash
flutter pub get
```

Import the package in any Dart file:

```dart
import 'package:pro_responsive/pro_responsive.dart';
```

---

## How It Works — Core Concepts

### 1. Screen Type Detection

The package uses a simple **width-based breakpoint system** defined in `ResponsiveConstraints`:

| Screen Type | Width Range     |
|-------------|-----------------|
| `mobile`    | 0 – 599 px      |
| `tablet`    | 600 – 899 px    |
| `desktop`   | 900 – 1199 px   |
| `tv`        | 1200 px and up  |

Internally, `DeviceInfo.getScreenType(width, orientation)` runs on every layout change and returns the correct `ScreenType` enum value.

```dart
// ScreenType enum
enum ScreenType { mobile, tablet, desktop, tv }
```

### 2. DeviceInfo Object

Every responsive widget exposes a `DeviceInfo` object, which is created from the current `Size` using `LayoutBuilder` constraints (not `MediaQuery`). This means it's **layout-aware**, not just window-aware — safe to use inside scrollables, side panels, and nested layouts.

```dart
class DeviceInfo {
  final ScreenType screenType;   // mobile | tablet | desktop | tv
  final Orientation orientation; // portrait | landscape
  final Size screenSize;         // full Size object
  final double width;
  final double height;

  // Convenience getters
  bool get isMobile  => screenType == ScreenType.mobile;
  bool get isTablet  => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;
  bool get isTV      => screenType == ScreenType.tv;
  bool get isPortrait  => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
}
```

---

## Widgets & APIs

---

### ResponsiveBuilder

The **core widget** of the package. It wraps a `LayoutBuilder` and calls the appropriate builder based on the detected `ScreenType` and orientation.

#### How it works internally:
1. `LayoutBuilder` fires with current `BoxConstraints`.
2. `DeviceInfo.fromSize(Size(maxWidth, maxHeight))` classifies the screen.
3. Priority check: specific device builder → orientation builder → general `builder` fallback.

#### Basic usage:

```dart
ResponsiveBuilder(
  builder: (context, deviceInfo) {
    return Text('Screen: ${deviceInfo.screenType}');
  },
)
```

#### With per-device builders:

```dart
ResponsiveBuilder(
  builder: (context, deviceInfo) => const DefaultLayout(),
  mobileBuilder: const MobileLayout(),
  tabletBuilder: const TabletLayout(),
  desktopBuilder: const DesktopLayout(),
  tvBuilder: const TvLayout(),
)
```

> ⚠️ **Priority rule**: If `mobileBuilder` is provided and the screen is mobile, it is returned immediately — the `builder` fallback is **never called** for that device type.

#### With orientation-specific builders:

```dart
ResponsiveBuilder(
  builder: (context, deviceInfo) => const DefaultLayout(),
  portraitBuilder: const PortraitLayout(),
  landscapeBuilder: const LandscapeLayout(),
)
```

#### Parameters:

| Parameter          | Type                                          | Required | Description                              |
|--------------------|-----------------------------------------------|----------|------------------------------------------|
| `builder`          | `Widget Function(BuildContext, DeviceInfo)`   | ✅ Yes   | Fallback builder for all devices         |
| `mobileBuilder`    | `Widget?`                                     | No       | Widget for mobile screens                |
| `tabletBuilder`    | `Widget?`                                     | No       | Widget for tablet screens                |
| `desktopBuilder`   | `Widget?`                                     | No       | Widget for desktop screens               |
| `tvBuilder`        | `Widget?`                                     | No       | Widget for TV screens                    |
| `portraitBuilder`  | `Widget?`                                     | No       | Widget for portrait orientation          |
| `landscapeBuilder` | `Widget?`                                     | No       | Widget for landscape orientation         |

---

### ResponsiveText

A `Text` widget that **automatically scales its font size** based on the detected `ScreenType`. If a size for a specific type is omitted, it falls back using a scale multiplier.

#### Fallback scale rules:
- Tablet → `mobileFontSize × 1.2` (if `tabletFontSize` not set)
- Desktop → `tabletFontSize × ...` → ultimately `mobileFontSize × 1.4`
- TV → ultimately `mobileFontSize × 1.6`

#### Usage:

```dart
ResponsiveText(
  'Hello, World!',
  mobileFontSize: 14,
  tabletFontSize: 20,
  desktopFontSize: 28,
  tvFontSize: 40,
  style: TextStyle(fontWeight: FontWeight.bold),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

#### Parameters:

| Parameter         | Type           | Required | Description                                    |
|-------------------|----------------|----------|------------------------------------------------|
| `text`            | `String`       | ✅ Yes   | The text to display                            |
| `mobileFontSize`  | `double`       | ✅ Yes   | Font size on mobile                            |
| `tabletFontSize`  | `double?`      | No       | Font size on tablet (fallback: mobile × 1.2)   |
| `desktopFontSize` | `double?`      | No       | Font size on desktop (fallback: tablet × ...)  |
| `tvFontSize`      | `double?`      | No       | Font size on TV (fallback: desktop × ...)      |
| `style`           | `TextStyle?`   | No       | Base text style (fontSize is overridden)       |
| `textAlign`       | `TextAlign?`   | No       | Text alignment                                 |
| `maxLines`        | `int?`         | No       | Maximum number of lines                        |
| `overflow`        | `TextOverflow?`| No       | How to handle visual overflow                  |

---

### ResponsiveGrid

A grid widget with **3 constructors** for different use cases. It automatically adjusts the number of columns (or tile size) per screen type.

---

#### Constructor 1 — Default (Small Lists)

Use when you have a **fixed, small list** of children.

```dart
ResponsiveGrid(
  spacing: 12,
  runSpacing: 12,
  padding: const EdgeInsets.all(8),
  columnCount: {
    ScreenType.mobile: 1,
    ScreenType.tablet: 2,
    ScreenType.desktop: 3,
    ScreenType.tv: 4,
  },
  children: List.generate(12, (i) => MyCard(i)),
)
```

> By default, `shrinkWrap: true` and `physics: NeverScrollableScrollPhysics()` — designed to sit inside a parent `SingleChildScrollView`.

---

#### Constructor 2 — `.builder()` (Large / Dynamic Lists)

Use for **thousands of items**. Items are built lazily on demand.

```dart
ResponsiveGrid.builder(
  itemCount: 10000,
  itemBuilder: (context, index) => MyCard(index),
  columnCount: {
    ScreenType.mobile: 2,
    ScreenType.tablet: 3,
    ScreenType.desktop: 6,
    ScreenType.tv: 8,
  },
  spacing: 12,
  runSpacing: 12,
  childAspectRatio: 1.2,
)
```

> `shrinkWrap: false` by default — this grid scrolls itself. Wrap in an `Expanded` widget inside a `Column`.

---

#### Constructor 3 — `.extent()` (Responsive Tile Sizes)

Use when you want tiles to **fill as many columns as possible** based on a max tile width instead of a fixed column count.

```dart
ResponsiveGrid.extent(
  itemCount: 5000,
  itemBuilder: (context, index) => MyCard(index),
  maxCrossAxisExtent: {
    ScreenType.mobile: 120.0,
    ScreenType.tablet: 180.0,
    ScreenType.desktop: 220.0,
    ScreenType.tv: 280.0,
  },
  spacing: 16,
  runSpacing: 16,
  childAspectRatio: 0.8,
)
```

#### Shared Parameters:

| Parameter          | Type                         | Default                        | Description                                   |
|--------------------|------------------------------|--------------------------------|-----------------------------------------------|
| `columnCount`      | `Map<ScreenType, int>`       | `{mobile:1, tab:2, desk:4, tv:6}` | Columns per screen type                    |
| `maxCrossAxisExtent`| `Map<ScreenType, double>?`  | `null`                         | Max tile width (for `.extent()` only)         |
| `spacing`          | `double`                     | `8.0`                          | Horizontal gap between tiles                  |
| `runSpacing`       | `double`                     | `8.0`                          | Vertical gap between rows                     |
| `padding`          | `EdgeInsetsGeometry?`        | `null`                         | Outer padding                                 |
| `shrinkWrap`       | `bool`                       | `true` (default) / `false` (builder) | Whether to size to content             |
| `childAspectRatio` | `double`                     | `1.0`                          | Width-to-height ratio of each tile            |
| `mainAxisExtent`   | `double?`                    | `null`                         | Fixed height per tile                         |

---

### ResponsiveList

A **feature-rich, production-ready list widget** for both simple and complex datasets. It uses `ListView.builder` under the hood for efficient lazy rendering.

#### Features at a glance:
- ✅ Lazy loading (efficient for large lists)
- ✅ Pull-to-refresh (`RefreshIndicator` integration)
- ✅ Automatic pagination / load more on scroll
- ✅ Loading state (initial + load more)
- ✅ Empty state widget
- ✅ Error state widget
- ✅ Header & Footer widgets
- ✅ Custom separators
- ✅ External scroll controller support
- ✅ Reverse scroll, horizontal scroll
- ✅ Cache extent configuration

#### Step 1 — Basic usage:

```dart
ResponsiveList<String>(
  items: myStringList,
  itemBuilder: (context, item, index) {
    return ListTile(
      title: Text(item),
      leading: CircleAvatar(child: Text('${index + 1}')),
    );
  },
  separator: const Divider(height: 1),
)
```

#### Step 2 — With pagination:

```dart
ResponsiveList<Product>(
  items: products,
  itemBuilder: (context, product, index) => ProductCard(product),
  onLoadMore: _loadMoreProducts,   // called when threshold is reached
  hasMore: hasMorePages,
  isLoading: initialLoading,
  isLoadingMore: paginationLoading,
  loadMoreThreshold: 0.7,          // trigger at 70% scroll depth
)
```

#### Step 3 — With pull-to-refresh:

```dart
ResponsiveList<Post>(
  items: posts,
  itemBuilder: (context, post, index) => PostTile(post),
  onRefresh: _refreshPosts,
)
```

#### Step 4 — With header, footer, and error state:

```dart
ResponsiveList<Item>(
  items: items,
  itemBuilder: (context, item, index) => ItemTile(item),
  header: const SectionHeader('My Items'),
  footer: const EndOfListBanner(),
  hasError: didFetchFail,
  errorMessage: 'Failed to load. Please try again.',
  emptyWidget: const Center(child: Text('No items yet!')),
)
```

#### How `onLoadMore` works internally:

The widget attaches a scroll listener to its `ScrollController`. On every scroll event:

```
if currentScrollPosition >= maxScrollExtent × loadMoreThreshold:
    call onLoadMore()
```

The callback is **not called** if `isLoadingMore == true` or `hasMore == false`, preventing duplicate fetches.

#### Full parameter reference:

| Parameter                    | Type                              | Default   | Description                                       |
|------------------------------|-----------------------------------|-----------|---------------------------------------------------|
| `items`                      | `List<T>`                         | ✅ required| Data source                                       |
| `itemBuilder`                | `Widget Function(ctx, T, index)`  | ✅ required| Item build function                               |
| `onLoadMore`                 | `Future<void> Function()?`        | `null`    | Pagination callback                               |
| `onRefresh`                  | `Future<void> Function()?`        | `null`    | Pull-to-refresh callback                         |
| `hasMore`                    | `bool`                            | `false`   | Whether more pages exist                          |
| `isLoading`                  | `bool`                            | `false`   | Initial loading state                             |
| `isLoadingMore`              | `bool`                            | `false`   | Pagination loading state                          |
| `hasError`                   | `bool`                            | `false`   | Error state flag                                  |
| `errorMessage`               | `String?`                         | `null`    | Error message text                                |
| `emptyWidget`                | `Widget?`                         | built-in  | Custom empty state widget                         |
| `loadingWidget`              | `Widget?`                         | built-in  | Custom initial loading widget                     |
| `loadingMoreWidget`          | `Widget?`                         | built-in  | Custom pagination loading widget                  |
| `errorWidget`                | `Widget?`                         | built-in  | Custom error widget                               |
| `separator`                  | `Widget?`                         | `null`    | Fixed separator between items                     |
| `separatorBuilder`           | `Widget Function(ctx, index)?`    | `null`    | Dynamic separator builder                         |
| `header`                     | `Widget?`                         | `null`    | Widget placed above the first item                |
| `footer`                     | `Widget?`                         | `null`    | Widget placed below the last item                 |
| `padding`                    | `EdgeInsetsGeometry?`             | `null`    | Padding around the list                           |
| `shrinkWrap`                 | `bool`                            | `false`   | Shrink to content size                            |
| `loadMoreThreshold`          | `double`                          | `0.8`     | Scroll depth (0.0–1.0) to trigger load more       |
| `reverse`                    | `bool`                            | `false`   | Reverse item order                                |
| `scrollDirection`            | `Axis`                            | `vertical`| Scroll axis                                       |
| `cacheExtent`                | `double?`                         | `null`    | Off-screen rendering buffer size                  |
| `refreshIndicatorDisplacement`| `double`                         | `40.0`    | Pull distance before refresh triggers             |

---

### ResponsiveContainer

A `Container` that constrains its **maximum width** based on the screen type. Useful for centered content layouts on large screens.

```dart
ResponsiveContainer(
  mobileWidth: double.infinity,
  tabletWidth: 600,
  desktopWidth: 900,
  tvWidth: 1200,
  padding: const EdgeInsets.all(24),
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  ),
  child: MyFormWidget(),
)
```

Internally, it wraps the child with an `Align` + `Container(constraints: BoxConstraints(maxWidth: ...))`.

---

### ResponsiveRow

A row that **wraps its children** and places a configurable number of them per row based on screen type, using a `Wrap` widget internally.

```dart
ResponsiveRow(
  breakpoints: {
    ScreenType.mobile: 1,
    ScreenType.tablet: 2,
    ScreenType.desktop: 4,
    ScreenType.tv: 6,
  },
  expandChildren: true,
  children: [
    FeatureCard('Speed'),
    FeatureCard('Security'),
    FeatureCard('Scale'),
    FeatureCard('Support'),
  ],
)
```

Each child is wrapped in a `SizedBox` with `width = 1 / itemsPerRow * totalWidth`. When `expandChildren: true`, each child is additionally wrapped in an `Expanded`.

---

## Context Extensions

The package adds `ResponsiveExtensions` on `BuildContext`, giving you responsive helpers **anywhere in the widget tree** without needing a `ResponsiveBuilder`.

```dart
// Screen type checks
context.isMobile      // bool
context.isTablet      // bool
context.isDesktop     // bool
context.isTV          // bool

// Orientation checks
context.isPortrait    // bool
context.isLandscape   // bool

// Dimensions
context.screenWidth   // double
context.screenHeight  // double

// Percentage helpers
double w = context.widthPercent(0.5);   // 50% of screen width
double h = context.heightPercent(0.3);  // 30% of screen height

// Responsive value selector
double padding = context.responsiveValue(
  mobile: 8.0,
  tablet: 16.0,
  desktop: 24.0,
  tv: 32.0,
);

// Full DeviceInfo object
DeviceInfo info = context.deviceInfo;
```

> ⚠️ Context extensions use `MediaQuery.of(context).size` rather than `LayoutBuilder` constraints. Use `ResponsiveBuilder` when you need constraint-level accuracy (e.g., inside a `Drawer` or side panel).

---

## Step-by-Step Usage Guide

### Step 1 — Install and import

```yaml
# pubspec.yaml
dependencies:
  pro_responsive: ^0.0.1
```

```dart
import 'package:pro_responsive/pro_responsive.dart';
```

### Step 2 — Understand your breakpoints

The package classifies screens as:
- **Mobile**: width < 600
- **Tablet**: 600 ≤ width < 900
- **Desktop**: 900 ≤ width < 1200
- **TV**: width ≥ 1200

### Step 3 — Wrap your layout with ResponsiveBuilder

```dart
@override
Widget build(BuildContext context) {
  return ResponsiveBuilder(
    builder: (context, deviceInfo) {
      return Scaffold(
        appBar: AppBar(title: Text('Device: ${deviceInfo.screenType}')),
        body: deviceInfo.isMobile
            ? const MobileBody()
            : const WideBody(),
      );
    },
  );
}
```

### Step 4 — Use ResponsiveText for adaptive typography

```dart
ResponsiveText(
  'Welcome',
  mobileFontSize: 18,
  tabletFontSize: 26,
  desktopFontSize: 36,
  style: const TextStyle(fontWeight: FontWeight.bold),
)
```

### Step 5 — Use ResponsiveGrid for adaptive grid layouts

```dart
Expanded(
  child: ResponsiveGrid.builder(
    itemCount: products.length,
    itemBuilder: (context, index) => ProductCard(products[index]),
    columnCount: {
      ScreenType.mobile: 2,
      ScreenType.tablet: 3,
      ScreenType.desktop: 5,
      ScreenType.tv: 7,
    },
    spacing: 12,
    runSpacing: 12,
  ),
)
```

### Step 6 — Use ResponsiveList for data-driven lists

```dart
Expanded(
  child: ResponsiveList<Article>(
    items: articles,
    itemBuilder: (context, article, index) => ArticleTile(article),
    onLoadMore: fetchNextPage,
    hasMore: true,
    isLoadingMore: isLoadingMore,
    onRefresh: refreshFeed,
    separator: const Divider(),
  ),
)
```

### Step 7 — Use context extensions for one-off decisions

```dart
Padding(
  padding: EdgeInsets.all(context.responsiveValue(
    mobile: 8,
    tablet: 16,
    desktop: 24,
  )),
  child: child,
)
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:pro_responsive/pro_responsive.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Responsive Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Dashboard',
          mobileFontSize: 18,
          desktopFontSize: 28,
        ),
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceInfo) {
          return Column(
            children: [
              // Adaptive info banner
              ResponsiveContainer(
                tabletWidth: 700,
                desktopWidth: 1000,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Viewing on: ${deviceInfo.screenType} | '
                  '${deviceInfo.orientation}',
                ),
              ),

              // Adaptive grid
              Expanded(
                child: ResponsiveGrid.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) => Card(
                    child: Center(child: Text('Item $index')),
                  ),
                  columnCount: {
                    ScreenType.mobile: 2,
                    ScreenType.tablet: 3,
                    ScreenType.desktop: 5,
                    ScreenType.tv: 8,
                  },
                  spacing: 8,
                  runSpacing: 8,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## API Reference

### Exported Symbols

| Symbol                 | Type        | Description                                      |
|------------------------|-------------|--------------------------------------------------|
| `ScreenType`           | `enum`      | `mobile`, `tablet`, `desktop`, `tv`             |
| `DeviceInfo`           | `class`     | Screen type, orientation, size, width, height   |
| `ResponsiveConstraints`| `class`     | Static breakpoint constants                      |
| `ResponsiveBuilder`    | `Widget`    | Core layout decision widget                      |
| `ResponsiveText`       | `Widget`    | Auto-scaling text                                |
| `ResponsiveGrid`       | `Widget`    | Adaptive grid (3 constructors)                   |
| `ResponsiveList<T>`    | `Widget`    | Full-featured adaptive list                      |
| `ResponsiveContainer`  | `Widget`    | Max-width responsive container                   |
| `ResponsiveRow`        | `Widget`    | Wrapping row with per-screen column count        |
| `ResponsiveExtensions` | `extension` | Context extensions for inline responsive logic   |

### Breakpoint Constants (`ResponsiveConstraints`)

| Constant         | Value  |
|------------------|--------|
| `mobileMaxWidth` | 599    |
| `tabletMinWidth` | 600    |
| `tabletMaxWidth` | 899    |
| `desktopMinWidth`| 900    |
| `desktopMaxWidth`| 1199   |
| `tvMinWidth`     | 1200   |

---

## Requirements

- Flutter: `>=1.17.0`
- Dart SDK: `>=3.7.0`
- No third-party dependencies — uses only `flutter/material.dart`
