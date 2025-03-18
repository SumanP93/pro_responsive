import 'package:flutter/material.dart';
import 'package:pro_responsive/pro_responsive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive UI Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive UI Demo')),
      body: ResponsiveBuilder(
        builder: (context, deviceInfo) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device info card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device Type: ${deviceInfo.screenType}'),
                      Text('Orientation: ${deviceInfo.orientation}'),
                      Text('Screen Size: ${deviceInfo.screenSize}'),
                      Text('Width: ${deviceInfo.width}'),
                      Text('Height: ${deviceInfo.height}'),
                    ],
                  ),
                ),
              ),

              // Responsive text example
              Center(
                child: ResponsiveText(
                  'This text changes size based on screen',
                  mobileFontSize: 16,
                  tabletFontSize: 24,
                  desktopFontSize: 32,
                  tvFontSize: 48,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Responsive Grid example
              Expanded(
                child: ResponsiveGrid(
                  padding: const EdgeInsets.all(16),
                  spacing: 16,
                  runSpacing: 16,
                  columnCount: {ScreenType.mobile: 1, ScreenType.tablet: 2, ScreenType.desktop: 3, ScreenType.tv: 4},
                  children: List.generate(12, (index) {
                    return Container(
                      color: Colors.blue[(index + 1) * 100],
                      child: Center(child: Text('Item $index', style: const TextStyle(color: Colors.white))),
                    );
                  }),
                ),
              ),
            ],
          );
        },

        // Alternative specific builders
        mobileBuilder: MobileHorizontalLayout(), //deviceInfo.isPortrait ? null : const MobileHorizontalLayout(),
      ),
    );
  }
}

class MobileHorizontalLayout extends StatelessWidget {
  const MobileHorizontalLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Custom Mobile Horizontal Layout'));
  }
}
