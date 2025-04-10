import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as http;

class HttpHelper {
  /// 根据相传入的数据，得到相应页面数据
  // Future<HttpResult> getHtml(HttpItem item) async {
  //   // 返回参数
  //   HttpResult result = HttpResult();
  //   try {
  //     // 准备请求并发送
  //     final response = await _sendRequest(item);
  //     await _getData(response, item, result);
  //   } catch (e) {
  //     result.html = e.toString();
  //   }

  //   // 重置请求（如果需要）
  //   if (item.isReset) {
  //     item.reset();
  //   }

  //   return result;
  // }

  // /// 发送请求
  // Future<http.Response> _sendRequest(HttpItem item) async {
  //   // 创建dio实例
  //   final dio = http.Dio();

  //   // 设置请求头
  //   final headers = Map<String, String>.from(item.header);
  //   headers[HttpHeaders.acceptHeader] =
  //       item.accept ?? 'text/html, application/xhtml+xml, */*';
  //   headers[HttpHeaders.contentTypeHeader] = item.contentType ?? 'text/html';
  //   headers[HttpHeaders.userAgentHeader] = item.userAgent ?? 'Mozilla/5.0';

  //   // 准备请求数据
  //   dynamic data;
  //   if (item.method.toUpperCase() == 'POST') {
  //     if (item.postDataType == PostDataType.string && item.postdata != null) {
  //       data = item.postdata;
  //     } else if (item.postDataType == PostDataType.byte &&
  //         item.postdataByte != null) {
  //       data = item.postdataByte;
  //     }
  //   }

  //   // 发起请求
  //   final response = await dio.request(
  //     item.url,
  //     options: http.Options(
  //       method: item.method,
  //       headers: headers,
  //       responseType: http.ResponseType.bytes,
  //     ),
  //     data: data,
  //   );

  //   // 转换为http.Response格式
  //   return http.Response(
  //     response.data,
  //     response.statusCode ?? 0,
  //     headers: response.headers.map,
  //     reasonPhrase: response.statusMessage,
  //   );
  // }

  // /// 获取数据并解析
  // Future<void> _getData(
  //   http.Response response,
  //   HttpItem item,
  //   HttpResult result,
  // ) async {
  //   result.statusCode = response.statusCode;
  //   result.statusDescription = response.reasonPhrase ?? '';

  //   // 获取Cookie
  //   if (response.headers.containsKey('set-cookie')) {
  //     result.cookie = response.headers['set-cookie']!;
  //   }

  //   // 获取返回值
  //   if (response.statusCode == 200) {
  //     // 自动检测编码
  //     String encoding =
  //         response.headers[HttpHeaders.contentEncodingHeader] ?? 'utf-8';
  //     result.html = utf8.decode(response.bodyBytes);
  //   } else {
  //     result.html = 'Error: ${response.reasonPhrase}';
  //   }
  // }
}

class HttpItem {
  String url;
  String method = 'GET';
  String? accept;
  String? contentType;
  String? userAgent;
  String? postdata;
  Uint8List? postdataByte;
  PostDataType postDataType = PostDataType.string;
  bool isToLower = false;
  bool isReset = false;
  Map<String, String> header = {};

  HttpItem(this.url);

  void reset() {
    postdata = null;
    postdataByte = null;
    isReset = false;
  }
}

class HttpResult {
  String cookie = '';
  String statusDescription = '';
  int statusCode = 0;
  String html = '';
}

/// Post数据的格式
enum PostDataType { string, byte }
