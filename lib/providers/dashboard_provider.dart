import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {

  final api = ref.watch(apiProvider);

  return await api.getDashboardStats();
});