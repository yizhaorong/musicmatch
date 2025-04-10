import 'dart:io';
import 'package:flutter/material.dart';
import 'package:musicmatch/services/storage_service.dart';
import 'package:musicmatch/views/screens/login_page.dart';
import 'package:musicmatch/views/screens/song_list_page.dart';
import 'package:window_size/window_size.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:toastification/toastification.dart';

void main() {
  // 初始化桌面窗口
  WidgetsFlutterBinding.ensureInitialized();
  DesktopWindow.setBorders(false);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(const Size(1200, 900));
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: '云音乐歌曲修复',
        routes: {
          '/':
              (context) => FutureBuilder<Widget>(
                future: _checkLoginStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return snapshot.data ?? LoginPage();
                },
              ),
          '/songlist': (context) => SongListPage(),
        },
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }

  Future<Widget> _checkLoginStatus() async {
    try {
      final checkLogin = await StorageService.read(
        'NeteaseMusic',
        'LoginCheck',
      );
      final isLoggedIn = checkLogin?.toLowerCase() == 'true';
      return isLoggedIn ? SongListPage() : LoginPage();
    } catch (e) {
      // 读取存储出错时返回登录页
      return LoginPage();
    }
  }
}
