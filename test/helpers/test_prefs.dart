import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:valvn/core/storage/prefs.dart';

/// [Prefs] backed by an in-memory platform (no plugins needed).
Future<Prefs> createTestPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map.of(values));
  return Prefs.create();
}
