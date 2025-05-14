// 新建一个文件 search_bar.dart
import 'package:flutter/material.dart';

class MusicSearchBar extends StatelessWidget {
  final String searchKeyword;
  final VoidCallback onSearch;
  final ValueChanged<String> onSearchKeywordChanged;

  const MusicSearchBar({
    super.key,
    required this.searchKeyword,
    required this.onSearch,
    required this.onSearchKeywordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: searchKeyword),
              onChanged: onSearchKeywordChanged,
              onSubmitted: (_) => onSearch(),
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
          ElevatedButton(onPressed: onSearch, child: Text('搜索')),
        ],
      ),
    );
  }
}
