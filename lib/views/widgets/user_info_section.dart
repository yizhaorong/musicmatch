import 'package:flutter/material.dart';
import 'package:musicmatch/models/cloud_info.dart';
import 'package:musicmatch/models/user.dart';
import 'package:musicmatch/services/common_service.dart';

class UserInfoSection extends StatelessWidget {
  final User? user;
  final CloudInfo? cloudInfo;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const UserInfoSection({
    super.key,
    required this.user,
    required this.cloudInfo,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child:
                user?.avatarUrl != null
                    ? Image.network(
                      user!.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: 60);
                      },
                    )
                    : Icon(Icons.person, size: 60),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(onPressed: onLogout, child: Text('退出登录')),
                    SizedBox(width: 8),
                    Text('UID: ${user?.userId ?? ''}'),
                    SizedBox(width: 8),
                    Text('Name: ${user?.nickname ?? ''}'),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(onPressed: onRefresh, child: Text('刷新网盘')),
                    SizedBox(width: 8),
                    Text(
                      '音乐云盘容量: ${CommonService.getFileSize(double.parse(cloudInfo?.size ?? '0'))} / ${CommonService.getFileSize(double.parse(cloudInfo?.maxSize ?? '0'))}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
