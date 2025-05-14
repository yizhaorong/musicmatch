import 'dart:convert';
import 'package:crypto/crypto.dart';

/// MD5加密工具类
class MD5Service {
  // 私有构造函数
  MD5Service._();

  /// 单例实例
  static final MD5Service _instance = MD5Service._();

  /// 获取单例
  factory MD5Service() => _instance;

  /// MD5加密方法
  String encrypt(String input) {
    if (input.isEmpty) return '';

    // 转换为UTF-8字节数组
    var bytes = utf8.encode(input);

    // 生成MD5哈希
    var digest = md5.convert(bytes);

    // 返回16进制字符串
    return digest.toString();
  }

  /// 兼容Java风格的MD5加密（逐字节处理）
  String encryptJavaStyle(String input) {
    if (input.isEmpty) return '';

    var bytes = utf8.encode(input);
    var digest = md5.convert(bytes);

    StringBuffer hexString = StringBuffer();
    for (var byte in digest.bytes) {
      hexString.write(byte.toRadixString(16).padLeft(2, '0'));
    }

    return hexString.toString();
  }
}
