import 'package:logger/logger.dart';

class LoggerService {
  // 私有构造函数
  LoggerService._internal();

  // 单例实例
  static final LoggerService _instance = LoggerService._internal();

  // Logger 实例
  static final Logger _logger = Logger();

  // 静态方法
  static void d(String message) {
    _logger.d(message);
  }

  static void i(String message) {
    _logger.i(message);
  }

  static void w(String message) {
    _logger.w(message);
  }

  static void e(String message) {
    _logger.e(message);
  }

  static void v(String message) {
    _logger.v(message);
  }

  static void wtf(String message) {
    _logger.wtf(message);
  }
}
