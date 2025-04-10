import 'package:flutter/material.dart';
import 'package:musicmatch/models/cloud_file.dart';
import 'package:musicmatch/models/song.dart';
import 'package:musicmatch/models/user.dart';
import 'package:musicmatch/services/common_service.dart';
import 'package:musicmatch/services/song_service.dart';
import 'package:musicmatch/services/toast_service.dart';
import 'package:musicmatch/services/user_service.dart';
import 'package:path/path.dart' as p;

class RecommendSongListPage extends StatefulWidget {
  CloudFile selectedSong;

  // 构造函数，接收参数
  RecommendSongListPage({super.key, required this.selectedSong});

  @override
  _RecommendSongListPageState createState() => _RecommendSongListPageState();
}

class _RecommendSongListPageState extends State<RecommendSongListPage> {
  List<Song> songList = [];

  User? user;
  String searchKeyword = '';
  String targetId = '';
  final ScrollController _controller = ScrollController();
  bool _isLoading = false; // 加载状态标志
  bool _canLoadMore = true; // 是否可以加载更多

  @override
  void initState() {
    super.initState();
    user = UserService().user;
    searchKeyword = p.basenameWithoutExtension(widget.selectedSong.fileName);
    _onRefresh();
    // 添加滚动监听器
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      songList.clear();
      _canLoadMore = true; // 重置加载更多状态
    });
    await _loadMoreItems();
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_canLoadMore) return;

    setState(() {
      _isLoading = true;
    });

    // 添加数据
    final songs = await SongService().searchSong(searchKeyword);
    _canLoadMore = false;
    songList.addAll(songs);
    setState(() {
      songList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('网易云音乐匹配')),
      body: Column(
        children: [
          // 用户信息区域
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(Icons.person, size: 60),
                ),
                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '歌曲ID: ${widget.selectedSong.songId.toString()}',
                          ),
                          SizedBox(width: 16),
                          Text(
                            '文件名: ${widget.selectedSong.fileName.toString()}',
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('歌名: ${widget.selectedSong.name.toString()}'),
                          SizedBox(width: 16),
                          Text('歌手: ${widget.selectedSong.artist.toString()}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 搜索栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    // 创建一个类成员变量来保存 TextEditingController
                    controller: TextEditingController(text: searchKeyword),
                    onChanged: (value) {
                      searchKeyword = value;
                    },
                    // 添加回车键监听
                    onSubmitted: (value) {
                      _searchSongs();
                    },
                    decoration: InputDecoration(
                      hintText: '请输入搜索关键词',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _searchSongs();
                  },
                  child: Text('搜索'),
                ),
              ],
            ),
          ),

          // 列表标题
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    '歌名',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '歌手',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '专辑',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '时长',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 歌曲列表
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: songList.length + 1,
              itemBuilder: (context, index) {
                if (index == songList.length) {
                  if (_isLoading) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!_canLoadMore) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Center(child: Text('没有更多数据了')),
                    );
                  }
                  return SizedBox();
                }

                return GestureDetector(
                  onTap: () {
                    targetId = songList[index].songId.toString();
                    setState(() {
                      targetId;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('${index + 1}'),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Text(songList[index].songName.toString()),
                        ),
                        Expanded(child: Text(songList[index].artist)),
                        Expanded(child: Text(songList[index].album)),

                        Expanded(
                          child: Text(
                            CommonService.formatDuration(
                              int.parse(songList[index].duration),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 底部匹配区域
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('音乐云盘歌曲信息匹配纠正'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: widget.selectedSong.songId.toString(),
                        ),
                        decoration: InputDecoration(
                          labelText: '云盘文件ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: targetId.toString(),
                        ),
                        onChanged: (value) => {targetId = value},
                        decoration: InputDecoration(
                          labelText: '歌曲ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _handleMatchCorrection();
                      },
                      child: Text('匹配纠正'),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _searchSongs() async {
    songList = await SongService().searchSong(searchKeyword);
    setState(() {
      songList;
    });
  }

  _handleMatchCorrection() async {
    final message = await SongService().handleMatchCorrection(
      user?.userId ?? '',
      widget.selectedSong.songId.toString(),
      targetId,
    );
    ToastService.showToast(message);
  }
}
