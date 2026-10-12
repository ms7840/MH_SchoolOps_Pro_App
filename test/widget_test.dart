import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schoolops_pro/app/app.dart';
import 'package:schoolops_pro/core/di/core_providers.dart';
import 'package:schoolops_pro/core/storage/local_cache_service.dart';

class MockLocalCacheService extends LocalCacheService {
  final Map<String, dynamic> _memory = {};

  @override
  T? get<T>({required String boxName, required String key, T? defaultValue}) {
    return _memory['$boxName:$key'] as T? ?? defaultValue;
  }

  @override
  Future<void> put<T>({required String boxName, required String key, required T value}) async {
    _memory['$boxName:$key'] = value;
  }
}

void main() {
  testWidgets('App root widget loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCacheProvider.overrideWithValue(MockLocalCacheService()),
        ],
        child: const SchoolOpsApp(),
      ),
    );
    expect(find.byType(SchoolOpsApp), findsOneWidget);
  });
}
