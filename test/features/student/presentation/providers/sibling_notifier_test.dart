import 'package:flutter_test/flutter_test.dart';
import 'package:schoolops_pro/core/storage/local_cache_service.dart';
import 'package:schoolops_pro/features/student/presentation/providers/sibling_notifier.dart';

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
  late MockLocalCacheService mockCache;
  late SiblingNotifier notifier;

  setUp(() {
    mockCache = MockLocalCacheService();
    notifier = SiblingNotifier(localCache: mockCache);
  });

  test('should initialize with default siblings and first child selected', () {
    expect(notifier.state.siblings.length, 2);
    expect(notifier.state.activeSibling?.studentId, 'std_001');
    expect(notifier.state.activeSibling?.fullName, 'Aarav Sharma');
  });

  test('should update activeSibling when switchSibling is called', () async {
    await notifier.switchSibling('std_002');

    expect(notifier.state.activeSibling?.studentId, 'std_002');
    expect(notifier.state.activeSibling?.fullName, 'Ananya Sharma');
  });
}
