import 'dart:async';
import 'package:flutter/material.dart';
import 'package:musicmatch/services/http_service.dart';
import 'package:musicmatch/services/user_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String unikey = '';
  String? qrCodeUrl;
  Timer? _loginCheckTimer;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  void dispose() {
    _loginCheckTimer?.cancel();
    super.dispose();
  }

  void loadSettings() async {
    loadQrCodeImage();
    startLoginCheck();
  }

  // 开始检查登录状态
  void startLoginCheck() {
    _loginCheckTimer?.cancel();
    _loginCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        final apiUrl =
            'https://music.163.com/api/login/qrcode/client/login?type=1&key=$unikey';
        var response = await HttpService.getHtml(apiUrl);

        if (response != null && response.data != null) {
          if (response.data['code']?.toString() == '803') {
            // 登录成功
            _loginCheckTimer?.cancel();
            // 获取响应头中的cookie
            final cookies = response.headers['set-cookie'];
            if (cookies != null && cookies.isNotEmpty) {
              // 更新cookie
              var wyCookie = cookies.join('; ');
              UserService().updateCookie(wyCookie);
              // 登录成功后跳转到歌单页面
              // 需要在 MaterialApp 的 routes 中注册 '/songlist' 路由
              // 例如: routes: {'/songlist': (context) => SongListPage()}
              Navigator.pushReplacementNamed(context, '/songlist');
            }
          } else if (response.data['code']?.toString() == '801') {
            // 等待扫码
          } else if (response.data['code']?.toString() == '802') {
            // 待确认
          } else {
            // 二维码过期，重新获取
            loadQrCodeImage();
          }
        }
      } catch (e) {
        showError(e.toString());
      }
    });
  }

  void loadQrCodeImage() async {
    var key = await UserService().fetchLoginKey();
    if (key != null) {
      unikey = key.toString();
      qrCodeUrl = 'https://music.163.com/login?codekey=$unikey';
      setState(() {});
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('错误'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadUIDName() async {
    UserService().fetchUserInfo();
  }

  Future<void> loadCloudInfo() async {
    UserService().fetchCloudInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Netease Music Cloud Match')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // 点击刷新二维码
                loadQrCodeImage();
              },
              child: QrImageView(
                data: qrCodeUrl ?? '',
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text('请使用网易云音乐APP扫码登录'),
          ],
        ),
      ),
    );
  }
}
