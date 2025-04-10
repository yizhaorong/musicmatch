import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  /// 读取存储值
  static Future<String?> read(String section, String key) async {
    // 使用 SharedPreferences 进行 KV 存储
    final prefs = await SharedPreferences.getInstance();
    // 使用 section 和 key 组合成唯一键值
    final storageKey = '${section}_$key';
    return prefs.getString(storageKey);
  }

  /// 写入存储值
  static Future<void> write(String section, String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    // 使用 section 和 key 组合成唯一键值
    final storageKey = '${section}_$key';
    await prefs.setString(storageKey, value);
  }

  static void delete(String s, String t) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('${s}_$t');
    });
  }
}
