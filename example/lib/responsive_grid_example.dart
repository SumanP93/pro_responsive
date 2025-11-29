import 'package:flutter/material.dart';
import 'package:pro_responsive/pro_responsive.dart';

/// Example demonstrating efficient usage of ResponsiveGrid with all three constructors

class ResponsiveGridExampleApp extends StatelessWidget {
  const ResponsiveGridExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Grid Examples',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResponsiveGridExamplesPage(),
    );
  }
}

class ResponsiveGridExamplesPage extends StatelessWidget {
  const ResponsiveGridExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Responsive Grid Examples'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Small List'), Tab(text: 'Large List (Builder)'), Tab(text: 'Extent Delegate')],
          ),
        ),
        body: const TabBarView(children: [SmallListExample(), LargeListExample(), ExtentDelegateExample()]),
      ),
    );
  }
}

/// Example 1: Small list using children parameter (inefficient for large lists)
class SmallListExample extends StatelessWidget {
  const SmallListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Small List (Using children parameter)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Best for small, fixed lists. Uses shrinkWrap and NeverScrollableScrollPhysics by default.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Traditional usage - backward compatible
              ResponsiveGrid(
                spacing: 12,
                runSpacing: 12,
                padding: const EdgeInsets.all(8),
                children: List.generate(12, (index) => _buildGridItem(index, Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 2: Large list using builder (EFFICIENT for large datasets)
class LargeListExample extends StatelessWidget {
  const LargeListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Large List with Builder (EFFICIENT)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Uses lazy loading with itemBuilder. Items are built on demand. Scrollable by default.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Efficient usage for large lists
          Expanded(
            child: ResponsiveGrid.builder(
              itemCount: 10000, // Can handle thousands of items efficiently
              itemBuilder: (context, index) {
                return _buildGridItem(index, Colors.green);
              },
              columnCount: const {ScreenType.mobile: 2, ScreenType.tablet: 3, ScreenType.desktop: 6, ScreenType.tv: 8},
              spacing: 12,
              runSpacing: 12,
              padding: const EdgeInsets.all(8),
              childAspectRatio: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 3: MaxCrossAxisExtent delegate (EFFICIENT for responsive tiles)
class ExtentDelegateExample extends StatelessWidget {
  const ExtentDelegateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Max Cross Axis Extent (EFFICIENT)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Tiles adapt based on maximum size. Grid fits as many as possible per row.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Using MaxCrossAxisExtent delegate
          Expanded(
            child: ResponsiveGrid.extent(
              itemCount: 5000, // Efficient for large lists
              itemBuilder: (context, index) {
                return _buildGridItem(index, Colors.purple);
              },
              maxCrossAxisExtent: const {
                ScreenType.mobile: 120.0,
                ScreenType.tablet: 180.0,
                ScreenType.desktop: 220.0,
                ScreenType.tv: 280.0,
              },
              spacing: 16,
              runSpacing: 16,
              padding: const EdgeInsets.all(8),
              childAspectRatio: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper method to build grid items
Widget _buildGridItem(int index, Color color) {
  return Card(
    elevation: 4,
    color: color.withOpacity(0.1),
    child: Container(
      decoration: BoxDecoration(border: Border.all(color: color, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_on, color: color, size: 32),
            const SizedBox(height: 8),
            Text('Item $index', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    ),
  );
}
