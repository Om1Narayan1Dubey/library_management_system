import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';

class BorrowHistoryNotifier extends AsyncNotifier<List<dynamic>> {
  int _page = 0;
  bool hasMore = true;
  bool _isFetching = false;

  @override
  Future<List<dynamic>> build() async {
    _page = 0;
    hasMore = true;
    final api = ref.watch(apiProvider);
    final data = await api.getGlobalBorrowHistory(page: _page, size: 5);
    hasMore = (data?.length ?? 0) == 5;
    return data ?? [];
  }

  Future<void> fetchMore() async {
    if (!hasMore || _isFetching) return;

    _isFetching = true;
    try {
      _page++;
      final api = ref.read(apiProvider);
      final newData = await api.getGlobalBorrowHistory(page: _page, size: 5);

      hasMore = (newData?.length ?? 0) == 5;

      final currentList = state.value ?? [];
      state = AsyncData([...currentList, ...(newData ?? [])]);
    } finally {
      _isFetching = false;
    }
  }
}

final borrowHistoryProvider = AsyncNotifierProvider<BorrowHistoryNotifier, List<dynamic>>(BorrowHistoryNotifier.new);