import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';

class BooksNotifier extends AsyncNotifier<List<dynamic>> {
  int _page = 0;
  bool hasMore = true;
  bool _isFetching = false;
  String _searchQuery = '';

  @override
  Future<List<dynamic>> build() async {
    _page = 0;
    hasMore = true;
    final api = ref.watch(apiProvider);
    final data = await api.getAllBooks(page: _page, size: 5, search: _searchQuery);
    hasMore = (data?.length ?? 0) == 5;
    return data ?? [];
  }

  void search(String query) {
    _searchQuery = query;
    ref.invalidateSelf();
  }

  Future<void> fetchMore() async {
    if (!hasMore || _isFetching) return;

    _isFetching = true;
    try {
      _page++;
      final api = ref.read(apiProvider);
      final newData = await api.getAllBooks(page: _page, size: 5, search: _searchQuery);

      hasMore = (newData?.length ?? 0) == 5;

      final currentList = state.value ?? [];
      state = AsyncData([...currentList, ...(newData ?? [])]);
    } finally {
      _isFetching = false;
    }
  }
}
final booksProvider = AsyncNotifierProvider<BooksNotifier, List<dynamic>>(BooksNotifier.new);