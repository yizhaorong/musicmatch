import 'dart:convert';

class CommonService {
  /// 文件大小转换
  static String getFileSize(double len) {
    const sizes = ['B', 'KB', 'MB', 'GB'];
    int order = 0;
    double temp = len;

    while (temp >= 1024 && order + 1 < sizes.length) {
      order++;
      temp /= 1024;
    }
    return '${temp.toStringAsFixed(2)} ${sizes[order]}';
  }

  /// 时间戳转日期
  static String unixTimestampToDateTime(String timeStamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp));
    return date.toLocal().toString().substring(
      0,
      19,
    ); // 格式化为 YYYY-MM-DD HH:mm:ss
  }

  static String formatDuration(int milliseconds) {
    // 将毫秒转换为 Duration 对象
    Duration duration = Duration(milliseconds: milliseconds);

    // 提取时、分、秒
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);

    // 如果小时和分钟都为 0，只显示秒
    if (hours == 0 && minutes == 0) {
      return '${seconds.toString().padLeft(2, '0')}';
    } else if (hours > 0) {
      // 如果小时大于 0，返回 HH:mm:ss 格式
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // 如果小时为 0，返回 mm:ss 格式
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 判断Json是否有效
  static bool checkJson(String strJson) {
    try {
      if (strJson.isEmpty) {
        return false;
      } else {
        json.decode(strJson);
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
