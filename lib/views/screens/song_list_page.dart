import 'package:flutter/material.dart';
import 'package:musicmatch/models/cloud_info.dart';
import 'package:musicmatch/models/cloud_file.dart';
import 'package:musicmatch/models/user.dart';
import 'package:musicmatch/services/logger_service.dart';
import 'package:musicmatch/services/song_service.dart';
import 'package:musicmatch/services/toast_service.dart';
import 'package:musicmatch/services/user_service.dart';
import 'package:musicmatch/views/screens/login_page.dart';
import 'package:musicmatch/views/screens/recommend_song_list_page.dart';
import 'package:musicmatch/views/widgets/user_info_section.dart';
import 'package:musicmatch/views/widgets/music_search_bar.dart';
import 'package:musicmatch/views/widgets/song_list_item.dart';

class SongListPage extends StatefulWidget {
  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<CloudFile> songList = [];
  List<CloudFile> matchedSongList = [];
  CloudFile? selectedSong;
  User? user;
  CloudInfo? cloudInfo;
  String searchKeyword = '';
  String targetId = '';
  final ScrollController _controller = ScrollController();
  int _page = 1; // 当前页码
  bool _isLoading = false; // 加载状态标志
  bool _canLoadMore = true; // 是否可以加载更多

  @override
  void initState() {
    super.initState();
    UserService().getCookie().then((value) {
      _loadUserInfo();
      _loadCloudInfo();
      _loadMoreItems(); // 初次加载数据
    });

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
      _page = 1; // 重置页码
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
    Map<String, dynamic> result = await SongService.fetchSongs(_page);
    List<CloudFile> songs = result['songs'];
    final total = result['total'] as int;
    if (total <= songList.length + songs.length) {
      _canLoadMore = false;
    }
    songList.addAll(songs);
    if (searchKeyword.isEmpty) {
      matchedSongList = songList;
    } else {
      matchedSongList = _filterSongs();
    }
    setState(() {
      _page++;
      songList;
      matchedSongList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('网易云音乐匹配')),
      body: Column(
        children: [
          UserInfoSection(
            user: user,
            cloudInfo: cloudInfo,
            onRefresh: _onRefresh,
            onLogout: _logout,
          ),
          MusicSearchBar(
            searchKeyword: searchKeyword,
            onSearch: _searchSongs,
            onSearchKeywordChanged: (value) {
              searchKeyword = value;
            },
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
                  child: Text(
                    '文件ID',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '文件名称',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '大小',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '上传时间',
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
              itemCount: matchedSongList.length + 1,
              itemBuilder: (context, index) {
                if (index == matchedSongList.length) {
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
                    setState(() {
                      selectedSong = matchedSongList[index];
                    });
                  },
                  child: SongListItem(
                    index: index,
                    song: matchedSongList[index],
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
                          text: selectedSong?.songId.toString() ?? '',
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
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _smartMatch();
                      },
                      child: Text('智能匹配'),
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

  Future<void> _logout() async {
    await UserService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserService().fetchUserInfo();
      if (mounted) {
        setState(() {
          user = userInfo;
        });
      }
    } catch (e) {
      // 错误处理
      LoggerService.e('加载用户信息失败: $e');
    }
  }

  // 加载云盘信息
  Future<void> _loadCloudInfo() async {
    try {
      final info = await UserService().fetchCloudInfo();
      if (mounted) {
        setState(() {
          cloudInfo = info;
        });
      }
    } catch (e) {
      // 错误处理
      LoggerService.e('加载云盘信息失败: $e');
    }
  }

  _searchSongs() {
    matchedSongList = _filterSongs();
    setState(() {
      matchedSongList;
    });
  }

  _filterSongs() {
    matchedSongList =
        songList
            .where(
              (song) =>
                  song.fileName.toLowerCase().contains(
                    searchKeyword.toLowerCase(),
                  ) ||
                  song.songId.toString().contains(searchKeyword),
            )
            .toList();
    return matchedSongList;
  }

  _handleMatchCorrection() async {
    final message = await SongService().handleMatchCorrection(
      user?.userId ?? '',
      selectedSong?.songId.toString() ?? '',
      targetId,
    );
    ToastService.showToast(message);
  }

  void _smartMatch() async {
    if (selectedSong == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RecommendSongListPage(selectedSong: selectedSong!),
      ),
    );
  }
}
