import 'package:flutter/material.dart';

/// Callback for loading more items (pagination)
typedef LoadMoreCallback = Future<void> Function();

/// Callback for refreshing the list
typedef RefreshCallback = Future<void> Function();

/// Builder for list items
typedef ResponsiveListItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

/// Builder for separator between items
typedef SeparatorBuilder = Widget Function(BuildContext context, int index);

/// A highly efficient and customizable responsive list for large datasets.
///
/// Features:
/// - Lazy loading with ListView.builder for efficient rendering
/// - Pull-to-refresh support
/// - Pagination (load more) with automatic detection
/// - Loading states (initial, pagination, refresh)
/// - Empty state handling
/// - Error state handling
/// - Scroll controller access
/// - Customizable separators
/// - Header and footer support
/// - Shrink wrap support for nested scrollables
class ResponsiveList<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;

  /// Builder function for creating list items
  final ResponsiveListItemBuilder<T> itemBuilder;

  /// Callback for loading more items (pagination)
  final LoadMoreCallback? onLoadMore;

  /// Callback for pull-to-refresh
  final RefreshCallback? onRefresh;

  /// Whether there are more items to load
  final bool hasMore;

  /// Whether the list is currently loading initial data
  final bool isLoading;

  /// Whether the list is currently loading more items (pagination)
  final bool isLoadingMore;

  /// Whether an error occurred
  final bool hasError;

  /// Error message to display
  final String? errorMessage;

  /// Widget to display when the list is empty and not loading
  final Widget? emptyWidget;

  /// Widget to display when loading initial data
  final Widget? loadingWidget;

  /// Widget to display when loading more items (pagination)
  final Widget? loadingMoreWidget;

  /// Widget to display when an error occurs
  final Widget? errorWidget;

  /// Custom separator builder (for ListView.separated style)
  final SeparatorBuilder? separatorBuilder;

  /// Fixed separator widget (alternative to separatorBuilder)
  final Widget? separator;

  /// Header widget to display at the top of the list
  final Widget? header;

  /// Footer widget to display at the bottom of the list
  final Widget? footer;

  /// Padding around the list
  final EdgeInsetsGeometry? padding;

  /// Whether to shrink-wrap the list
  final bool shrinkWrap;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Scroll controller
  final ScrollController? controller;

  /// Threshold for triggering load more (0.0 to 1.0)
  /// Default is 0.8 (triggers when scrolled 80% of the way)
  final double loadMoreThreshold;

  /// Whether to reverse the list
  final bool reverse;

  /// The axis along which the scroll view scrolls
  final Axis scrollDirection;

  /// Whether to add automatic keep-alive to items
  final bool addAutomaticKeepAlives;

  /// Whether to add repaint boundaries to items
  final bool addRepaintBoundaries;

  /// The amount of space by which to inset the children
  final EdgeInsetsGeometry? itemPadding;

  /// Cache extent for the list view
  final double? cacheExtent;

  /// Key for the RefreshIndicator
  final Key? refreshIndicatorKey;

  /// Displacement for the RefreshIndicator
  final double refreshIndicatorDisplacement;

  /// Stroke width for the RefreshIndicator
  final double refreshIndicatorStrokeWidth;

  /// Creates an efficient responsive list with all features
  const ResponsiveList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasError = false,
    this.errorMessage,
    this.emptyWidget,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.errorWidget,
    this.separatorBuilder,
    this.separator,
    this.header,
    this.footer,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.loadMoreThreshold = 0.8,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.itemPadding,
    this.cacheExtent,
    this.refreshIndicatorKey,
    this.refreshIndicatorDisplacement = 40.0,
    this.refreshIndicatorStrokeWidth = 2.0,
  });

  @override
  State<ResponsiveList<T>> createState() => _ResponsiveListState<T>();
}

class _ResponsiveListState<T> extends State<ResponsiveList<T>> {
  late ScrollController _scrollController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    _initScrollController();
  }

  @override
  void didUpdateWidget(ResponsiveList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeScrollController();
      _initScrollController();
    }
  }

  void _initScrollController() {
    if (widget.controller != null) {
      _scrollController = widget.controller!;
      _isInternalController = false;
    } else {
      _scrollController = ScrollController();
      _isInternalController = true;
    }

    if (widget.onLoadMore != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _disposeScrollController() {
    if (widget.onLoadMore != null) {
      _scrollController.removeListener(_onScroll);
    }
    if (_isInternalController) {
      _scrollController.dispose();
    }
  }

  @override
  void dispose() {
    _disposeScrollController();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= threshold && widget.onLoadMore != null) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading widget for initial load
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingWidget ?? _buildDefaultLoadingWidget();
    }

    // Show error widget
    if (widget.hasError && widget.items.isEmpty) {
      return widget.errorWidget ?? _buildDefaultErrorWidget(widget.errorMessage);
    }

    // Show empty widget
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? _buildDefaultEmptyWidget();
    }

    // Build the list
    Widget listView = _buildListView();

    // Wrap with RefreshIndicator if onRefresh is provided
    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        key: widget.refreshIndicatorKey,
        onRefresh: widget.onRefresh!,
        displacement: widget.refreshIndicatorDisplacement,
        strokeWidth: widget.refreshIndicatorStrokeWidth,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildListView() {
    final itemCount = _calculateItemCount();

    if (widget.separatorBuilder != null || widget.separator != null) {
      return ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        reverse: widget.reverse,
        scrollDirection: widget.scrollDirection,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        cacheExtent: widget.cacheExtent,
        itemCount: itemCount,
        separatorBuilder: widget.separatorBuilder ?? (context, index) => widget.separator ?? const SizedBox.shrink(),
        itemBuilder: (context, index) => _buildItem(context, index),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      cacheExtent: widget.cacheExtent,
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildItem(context, index),
    );
  }

  int _calculateItemCount() {
    int count = 0;

    // Add header
    if (widget.header != null) count++;

    // Add items
    count += widget.items.length;

    // Add loading more indicator
    if (widget.isLoadingMore) count++;

    // Add footer
    if (widget.footer != null) count++;

    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    int currentIndex = index;

    // Handle header
    if (widget.header != null) {
      if (currentIndex == 0) {
        return widget.header!;
      }
      currentIndex--;
    }

    // Handle items
    if (currentIndex < widget.items.length) {
      Widget item = widget.itemBuilder(context, widget.items[currentIndex], currentIndex);

      if (widget.itemPadding != null) {
        item = Padding(padding: widget.itemPadding!, child: item);
      }

      return item;
    }
    currentIndex -= widget.items.length;

    // Handle loading more indicator
    if (widget.isLoadingMore) {
      if (currentIndex == 0) {
        return widget.loadingMoreWidget ?? _buildDefaultLoadingMoreWidget();
      }
      currentIndex--;
    }

    // Handle footer
    if (widget.footer != null) {
      if (currentIndex == 0) {
        return widget.footer!;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDefaultLoadingWidget() {
    return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
  }

  Widget _buildDefaultLoadingMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }

  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ],
          ],
        ),
      ),
    );
  }
}
