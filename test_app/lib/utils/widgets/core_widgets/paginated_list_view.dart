import 'package:test_app/exports.dart';

class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.separatorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;
  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildListView() {
    final itemCount = widget.items.length + (widget.isLoadingMore ? 1 : 0);

    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      color: widget.refreshIndicatorColor,
      backgroundColor: widget.refreshIndicatorBackgroundColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: itemCount,
        separatorBuilder:
            widget.separatorBuilder ??
            (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: LoadingWidget(),
              ),
            );
          }

          final item = widget.items[index];
          return widget.itemBuilder(context, item, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildListView();
  }
}

class PaginatedGridView<T> extends StatefulWidget {
  const PaginatedGridView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMoreData,
    required this.gridDelegate,
    super.key,
    this.emptyTitle = 'No items found',
    this.emptySubtitle = 'Check back later for more content',
    this.emptyIcon,
    this.errorMessage,
    this.onRetry,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final SliverGridDelegate gridDelegate;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyIcon;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double loadMoreThreshold;

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold &&
        !widget.isLoadingMore &&
        widget.hasMoreData &&
        widget.items.isNotEmpty) {
      widget.onLoadMore();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: EmptyStateWidget(
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          iconPath: widget.emptyIcon,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: RetryWidget(
        message: widget.errorMessage ?? 'Something went wrong',
        onRetry: widget.onRetry ?? widget.onRefresh,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: LoadingWidget(),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: widget.physics,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: widget.gridDelegate,
              padding: widget.padding,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return widget.itemBuilder(context, item, index);
              },
            ),
            if (widget.isLoadingMore && widget.items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: LoadingWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorState();
    }

    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingState();
    }

    if (widget.items.isEmpty && !widget.isLoading) {
      return _buildEmptyState();
    }

    return _buildGridView();
  }
}
