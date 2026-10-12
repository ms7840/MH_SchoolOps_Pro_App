import 'package:hive_flutter/hive_flutter.dart';
import '../constants/storage_constants.dart';

/// Local high-performance key-value caching service powered by Hive.
class LocalCacheService {
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(StorageConstants.userContextBox);
    await Hive.openBox(StorageConstants.siblingsBox);
    await Hive.openBox(StorageConstants.appPreferencesBox);
  }

  Box _getBox(String boxName) => Hive.box(boxName);

  Future<void> put<T>({required String boxName, required String key, required T value}) async {
    await _getBox(boxName).put(key, value);
  }

  T? get<T>({required String boxName, required String key, T? defaultValue}) {
    return _getBox(boxName).get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> delete({required String boxName, required String key}) async {
    await _getBox(boxName).delete(key);
  }

  Future<void> clearBox({required String boxName}) async {
    await _getBox(boxName).clear();
  }

  Future<void> clearAllUserCaches() async {
    await clearBox(boxName: StorageConstants.userContextBox);
    await clearBox(boxName: StorageConstants.siblingsBox);
  }
}
