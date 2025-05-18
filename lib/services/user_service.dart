import 'dart:collection';
import 'dart:convert';

import 'package:musicmatch/models/cloud_info.dart';
import 'package:musicmatch/models/user.dart';
import 'package:musicmatch/services/http_service.dart';
import 'package:musicmatch/services/logger_service.dart';
import 'package:musicmatch/services/storage_service.dart';

class UserService {
  String? cookies = '';
  User? user;
  CloudInfo? cloudInfo;
  // 私有构造函数
  UserService._() {
    // 初始化时从存储中读取cookie
    StorageService.read('NeteaseMusic', 'Cookie').then((value) {
      if (value != null && value.isNotEmpty) {
        cookies = value;
      }
    });
  }

  // 单例实例
  static final UserService _instance = UserService._();

  // 获取单例实例的工厂构造函数
  factory UserService() {
    return _instance;
  }

  Future<String?> fetchLoginKey() async {
    // Load QR Code
    try {
      final apiUrl = 'https://music.163.com/api/login/qrcode/unikey?type=1';
      var response = await HttpService.getHtml(apiUrl);
      if (response != null && response.data != null) {
        if (response.data['code']?.toString() == '200') {
          var unikey = response.data['unikey']!.toString();
          if (unikey.isNotEmpty) {
            return unikey;
          } else {
            return null;
          }
        } else {
          return null;
        }
      }
    } catch (e) {
      LoggerService.d(e.toString());
    }
    return null;
  }

  Future<User?> fetchUserInfo() async {
    try {
      final apiUrl = 'https://music.163.com/api/nuser/account/get';
      var response = await HttpService.getHtml(apiUrl, cookie: cookies);
      if (response != null && response.data != null) {
        if (response.data['code']?.toString() == '200') {
          // 将response.data['profile']转换为User对象
          final userProfile = response.data['profile'] as Map<String, dynamic>;
          final user = User.fromJson(userProfile);
          this.user = user;
          return user;
        }
      }
    } catch (e) {
      LoggerService.d(e.toString());
    }
    return null;
  }

  Future<CloudInfo?> fetchCloudInfo() async {
    try {
      final apiUrl = 'https://music.163.com/api/v1/cloud/get?limit=0';
      var response = await HttpService.getHtml(apiUrl, cookie: cookies);
      if (response != null && response.data != null) {
        Map<String, dynamic> jsonData = HashMap();
        if (response.data is String) {
          // 解析JSON
          jsonData = json.decode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        }
        if (jsonData['code']?.toString() == '200') {
          cloudInfo = CloudInfo.fromJson(jsonData);
          return cloudInfo;
        }
      }
    } catch (e) {
      LoggerService.d(e.toString());
    }
    return null;
  }

  void updateCookie(String cookies) async {
    this.cookies = cookies;
    // 保存cookie到文件
    await StorageService.write('NeteaseMusic', 'Cookie', cookies);
    await StorageService.write('NeteaseMusic', 'LoginCheck', 'true');
  }

  getCookie() async {
    cookies = await StorageService.read('NeteaseMusic', 'Cookie');
    return cookies;
  }

  logout() {
    cookies = '';
    user = null;
    cloudInfo = null;
    StorageService.delete('NeteaseMusic', 'Cookie');
    StorageService.delete('NeteaseMusic', 'LoginCheck');
  }
}
