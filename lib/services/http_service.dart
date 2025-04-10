import 'dart:math';

import 'package:dio/dio.dart' as http;

class HttpService {
  /// 获取网页源码
  static Future<http.Response?> getHtml(
    String url, {
    String? cookie = "",
  }) async {
    final dio = http.Dio(); // 创建dio实例
    try {
      // 设置请求头
      final options = http.Options(
        headers: {
          'Cookie': cookie ?? '',
          'x-from-src': _randomIp(),
          'X-Real-IP': _randomIp(),
          'X-Forwarded-For': _randomIp(),
        },
        contentType: 'application/json;charset=UTF-8',
      );

      // 发起 GET 请求
      final response = await dio.get(url, options: options);
      // 返回响应数据
      return response; // 确保响应数据格式为 String
    } catch (e) {
      // 输出错误信息
      print("Error: $e");
      return null;
    }
  }

  /// 生成随机IP地址
  static String _randomIp() {
    Random rnd = Random();
    return _longToIp(rnd.nextInt(1884890111 - 1884815360) + 1884815360);
  }

  /// 数字转换为IP地址
  static String _longToIp(int value) {
    return '${(value >> 24) & 0xFF}.${(value >> 16) & 0xFF}.${(value >> 8) & 0xFF}.${value & 0xFF}';
  }
}
