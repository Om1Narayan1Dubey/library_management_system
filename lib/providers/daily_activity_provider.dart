import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';

final dailyActivityProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String?>((ref, dateString) async {
  final api = ref.watch(apiProvider);
  final data = await api.getDailyActivityLogs(date: dateString);
  return data ?? {};
});