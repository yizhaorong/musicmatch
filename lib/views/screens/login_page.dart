import 'dart:async';
import 'package:flutter/material.dart';
import 'package:musicmatch/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '前往网易云音乐网页版进行登录后，复制Cookie',
                  hintText: '请输入网易云音乐网页版的Cookie',
                ),
                maxLines: 3,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    UserService().updateCookie(value);
                    // 更新Cookie后直接跳转到歌单页面
                    Navigator.pushReplacementNamed(context, '/songlist');
                  }
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
