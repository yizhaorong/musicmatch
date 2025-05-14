// 创建一个新文件 song_list_item.dart
import 'package:flutter/material.dart';
import 'package:musicmatch/models/cloud_file.dart';
import 'package:musicmatch/services/common_service.dart';

class SongListItem extends StatelessWidget {
  final int index;
  final CloudFile song;

  const SongListItem({super.key, required this.index, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('${index + 1}'),
          SizedBox(width: 16),
          Expanded(child: Text(song.songId.toString())),
          Expanded(flex: 2, child: Text(song.fileName)),
          Expanded(
            child: Text(CommonService.getFileSize(double.parse(song.fileSize))),
          ),
          Expanded(
            child: Text(CommonService.unixTimestampToDateTime(song.addTime)),
          ),
        ],
      ),
    );
  }
}
