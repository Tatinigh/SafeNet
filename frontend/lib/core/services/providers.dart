import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'hive_service.dart';

/// Provider for the API network client.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for the local Hive database.
/// Must be initialized in main() before app startup.
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
