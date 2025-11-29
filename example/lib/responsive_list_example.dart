import 'package:flutter/material.dart';
import 'package:pro_responsive/pro_responsive.dart';

/// Comprehensive examples demonstrating ResponsiveList with all features
void main() {
  runApp(const ResponsiveListExampleApp());
}

class ResponsiveListExampleApp extends StatelessWidget {
  const ResponsiveListExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive List Examples',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ResponsiveListExamplesPage(),
    );
  }
}

class ResponsiveListExamplesPage extends StatelessWidget {
  const ResponsiveListExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Responsive List Examples'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Basic'),
              Tab(text: 'Pagination'),
              Tab(text: 'Pull-to-Refresh'),
              Tab(text: 'Advanced'),
              Tab(text: 'Custom States'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BasicListExample(),
            PaginationExample(),
            RefreshExample(),
            AdvancedExample(),
            CustomStatesExample(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 1: Basic List
// ============================================================================
class BasicListExample extends StatelessWidget {
  const BasicListExample({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(100, (i) => 'Item ${i + 1}');

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Responsive List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Simple list with lazy loading. Only visible items are built.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue, child: Text('${index + 1}')),
                  title: Text(item),
                  subtitle: Text('Subtitle for item ${index + 1}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped: $item')));
                  },
                );
              },
              separator: const Divider(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 2: Pagination (Load More)
// ============================================================================
class PaginationExample extends StatefulWidget {
  const PaginationExample({super.key});

  @override
  State<PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<PaginationExample> {
  List<String> items = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 0;
  static const int itemsPerPage = 20;
  static const int totalPages = 10;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      items = List.generate(itemsPerPage, (i) => 'Item ${i + 1}');
      currentPage = 1;
      isLoading = false;
      hasMore = currentPage < totalPages;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      final startIndex = items.length;
      final newItems = List.generate(itemsPerPage, (i) => 'Item ${startIndex + i + 1}');
      items.addAll(newItems);
      currentPage++;
      isLoadingMore = false;
      hasMore = currentPage < totalPages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pagination Example', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Scroll to the bottom to load more items automatically.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loaded: ${items.length} items | Page: $currentPage/$totalPages',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Text('${index + 1}')),
                    title: Text(item),
                    subtitle: Text('Page ${(index ~/ itemsPerPage) + 1}'),
                  ),
                );
              },
              onLoadMore: _loadMore,
              hasMore: hasMore,
              isLoading: isLoading,
              isLoadingMore: isLoadingMore,
              loadMoreThreshold: 0.7, // Load more when 70% scrolled
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 3: Pull-to-Refresh
// ============================================================================
class RefreshExample extends StatefulWidget {
  const RefreshExample({super.key});

  @override
  State<RefreshExample> createState() => _RefreshExampleState();
}

class _RefreshExampleState extends State<RefreshExample> {
  List<String> items = [];
  bool isLoading = false;
  DateTime? lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      items = List.generate(30, (i) => 'Item ${i + 1}');
      isLoading = false;
      lastRefreshTime = DateTime.now();
    });
  }

  Future<void> _onRefresh() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      items = List.generate(30, (i) => 'Refreshed Item ${i + 1}');
      lastRefreshTime = DateTime.now();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List refreshed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pull-to-Refresh Example', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Pull down to refresh the list.', style: TextStyle(color: Colors.grey)),
                if (lastRefreshTime != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last refreshed: ${_formatTime(lastRefreshTime!)}',
                    style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: ResponsiveList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(item),
                  subtitle: Text('Index: $index'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        items.removeAt(index);
                      });
                    },
                  ),
                );
              },
              onRefresh: _onRefresh,
              isLoading: isLoading,
              separatorBuilder: (context, index) => const Divider(height: 1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// Example 4: Advanced - Pagination + Refresh + Header/Footer
// ============================================================================
class AdvancedExample extends StatefulWidget {
  const AdvancedExample({super.key});

  @override
  State<AdvancedExample> createState() => _AdvancedExampleState();
}

class _AdvancedExampleState extends State<AdvancedExample> {
  List<String> items = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      items = List.generate(15, (i) => 'Item ${i + 1}');
      currentPage = 1;
      isLoading = false;
      hasMore = true;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore) return;

    setState(() {
      isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      final startIndex = items.length;
      final newItems = List.generate(15, (i) => 'Item ${startIndex + i + 1}');
      items.addAll(newItems);
      currentPage++;
      isLoadingMore = false;
      hasMore = currentPage < 5; // Stop after 5 pages
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      items = List.generate(15, (i) => 'Item ${i + 1}');
      currentPage = 1;
      hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveList<String>(
      items: items,
      itemBuilder: (context, item, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            title: Text(item),
            subtitle: Text('This is a detailed subtitle for $item'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
      onLoadMore: _loadMore,
      onRefresh: _onRefresh,
      hasMore: hasMore,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      header: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Advanced Example', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Features: Pull-to-refresh + Pagination + Header/Footer', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              'Total Items: ${items.length} | Page: $currentPage/5',
              style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      footer: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[100],
        child: Center(
          child:
              hasMore
                  ? const Text('Scroll for more...')
                  : const Text('You\'ve reached the end!', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      loadMoreThreshold: 0.8,
    );
  }
}

// ============================================================================
// Example 5: Custom States (Empty, Error, Loading)
// ============================================================================
class CustomStatesExample extends StatefulWidget {
  const CustomStatesExample({super.key});

  @override
  State<CustomStatesExample> createState() => _CustomStatesExampleState();
}

class _CustomStatesExampleState extends State<CustomStatesExample> {
  List<String> items = [];
  bool isLoading = false;
  bool hasError = false;
  String stateType = 'empty'; // empty, loading, error, success

  void _showEmpty() {
    setState(() {
      items = [];
      isLoading = false;
      hasError = false;
      stateType = 'empty';
    });
  }

  void _showLoading() {
    setState(() {
      items = [];
      isLoading = true;
      hasError = false;
      stateType = 'loading';
    });
  }

  void _showError() {
    setState(() {
      items = [];
      isLoading = false;
      hasError = true;
      stateType = 'error';
    });
  }

  void _showSuccess() {
    setState(() {
      items = List.generate(20, (i) => 'Item ${i + 1}');
      isLoading = false;
      hasError = false;
      stateType = 'success';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Custom States Example', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Test different states with custom widgets', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(onPressed: _showEmpty, child: const Text('Empty')),
                    ElevatedButton(onPressed: _showLoading, child: const Text('Loading')),
                    ElevatedButton(onPressed: _showError, child: const Text('Error')),
                    ElevatedButton(onPressed: _showSuccess, child: const Text('Success')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveList<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(item));
              },
              isLoading: isLoading,
              hasError: hasError,
              errorMessage: 'Failed to load data. Please try again.',
              emptyWidget: _buildCustomEmptyWidget(),
              loadingWidget: _buildCustomLoadingWidget(),
              errorWidget: _buildCustomErrorWidget(),
              separator: const Divider(height: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'Nothing to see here!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text('Try adding some items to get started', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _showSuccess, icon: const Icon(Icons.add), label: const Text('Add Items')),
        ],
      ),
    );
  }

  Widget _buildCustomLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            'Loading awesome content...',
            style: TextStyle(fontSize: 16, color: Colors.blue[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t load your data. Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showSuccess,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
