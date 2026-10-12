import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/sibling_profile.dart';

class SiblingState {
  final List<SiblingProfile> siblings;
  final SiblingProfile? activeSibling;
  final bool isLoading;

  const SiblingState({
    this.siblings = const [],
    this.activeSibling,
    this.isLoading = false,
  });

  SiblingState copyWith({
    List<SiblingProfile>? siblings,
    SiblingProfile? activeSibling,
    bool? isLoading,
  }) {
    return SiblingState(
      siblings: siblings ?? this.siblings,
      activeSibling: activeSibling ?? this.activeSibling,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SiblingNotifier extends StateNotifier<SiblingState> {
  final LocalCacheService _localCache;

  SiblingNotifier({required LocalCacheService localCache})
      : _localCache = localCache,
        super(const SiblingState()) {
    _initializeSiblings();
  }

  void _initializeSiblings() {
    // Default demonstration sibling profiles for parents
    const demoSiblings = [
      SiblingProfile(
        studentId: 'std_001',
        fullName: 'Aarav Sharma',
        admissionNumber: 'ADM-2024-089',
        classSection: 'Grade 9 - Section A',
        rollNumber: '14',
      ),
      SiblingProfile(
        studentId: 'std_002',
        fullName: 'Ananya Sharma',
        admissionNumber: 'ADM-2025-142',
        classSection: 'Grade 5 - Section B',
        rollNumber: '07',
      ),
    ];

    // Read last active sibling ID from cache
    final savedSiblingId = _localCache.get<String>(
      boxName: StorageConstants.appPreferencesBox,
      key: StorageConstants.activeSiblingId,
    );

    final active = demoSiblings.firstWhere(
      (s) => s.studentId == savedSiblingId,
      orElse: () => demoSiblings.first,
    );

    state = SiblingState(
      siblings: demoSiblings,
      activeSibling: active,
    );
  }

  Future<void> switchSibling(String studentId) async {
    final matched = state.siblings.firstWhere(
      (s) => s.studentId == studentId,
      orElse: () => state.siblings.first,
    );

    state = state.copyWith(activeSibling: matched);

    await _localCache.put(
      boxName: StorageConstants.appPreferencesBox,
      key: StorageConstants.activeSiblingId,
      value: matched.studentId,
    );
  }
}

final siblingNotifierProvider =
    StateNotifierProvider<SiblingNotifier, SiblingState>((ref) {
  final localCache = ref.watch(localCacheProvider);
  return SiblingNotifier(localCache: localCache);
});

final activeSiblingProvider = Provider<SiblingProfile?>((ref) {
  return ref.watch(siblingNotifierProvider).activeSibling;
});
