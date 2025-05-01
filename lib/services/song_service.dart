import 'dart:collection';
import 'dart:convert';

import 'package:musicmatch/models/cloud_file.dart';
import 'package:musicmatch/models/song.dart';
import 'package:musicmatch/services/http_service.dart';
import 'package:musicmatch/services/logger_service.dart';
import 'package:musicmatch/services/user_service.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:path/path.dart' as p;

class SongService {
  static Future<Map<String, dynamic>> fetchSongs(int pageIndex) async {
    List<CloudFile> songs = [];
    try {
      int pageSize = 200;
      final apiUrl =
          "https://music.163.com/api/v1/cloud/get?limit=$pageSize&offset=${(pageIndex - 1) * pageSize}";
      var response = await HttpService.getHtml(
        apiUrl,
        cookie: UserService().cookies,
      );
      if (response != null && response.data != null) {
        Map<String, dynamic> jsonData = HashMap();
        if (response.data is String) {
          // 解析JSON
          jsonData = json.decode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        }
        if (jsonData['code']?.toString() == '200' && jsonData['data'] != null) {
          final data = jsonData['data'] as List<dynamic>;
          final total = jsonData['count'] as int;
          final songList =
              data.map((songData) => CloudFile.fromMap(songData)).toList();
          songs.addAll(songList);
          return {'songs': songs, 'total': total};
        }
      } else {
        return {'songs': songs, 'total': 0};
      }
    } catch (e) {
      LoggerService.d(e.toString());
    }
    return {'songs': songs, 'total': 0};
  }

  Future<int> checkSongStatus(String songId) async {
    try {
      if (songId == "0") {
        return -1;
      } else {
        String apiUrl = "https://music.163.com/api/song/detail/?ids=[$songId]";
        var response = await HttpService.getHtml(
          apiUrl,
          cookie: UserService().cookies,
        );
        if (response != null && response.data != null) {
          Map<String, dynamic> jsonData = HashMap();
          if (response.data is String) {
            // 解析JSON
            jsonData = json.decode(response.data);
          } else if (response.data is Map<String, dynamic>) {
            jsonData = response.data;
          }
          if (jsonData['code']?.toString() == '200' &&
              jsonData['songs'] != null &&
              jsonData['songs'].isNotEmpty) {
            return 1;
          }
        }
        return 0;
      }
    } catch (e) {
      LoggerService.d(e.toString());
      return -1;
    }
  }

  Future<bool> checkCloudFileStatus(String songId) async {
    try {
      String apiUrl =
          "https://music.163.com/api/cloud/get/byids?songIds=[$songId]";
      var response = await HttpService.getHtml(
        apiUrl,
        cookie: UserService().cookies,
      );
      if (response != null && response.data != null) {
        Map<String, dynamic> jsonData = HashMap();
        if (response.data is String) {
          // 解析JSON
          jsonData = json.decode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        }
        if (jsonData['code']?.toString() == '200' &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          return true;
        }
      }
      return false; // 返回 false，表示错误发生
    } catch (e) {
      LoggerService.d(e.toString());
      return false; // 返回 false，表示错误发生
    }
  }

  Future<String> handleMatchCorrection(
    String uid,
    String sid,
    String asid,
  ) async {
    try {
      if (sid.isEmpty) {
        LoggerService.d("请选择云盘文件");
        return "请选择云盘文件";
      } else if (asid.isEmpty) {
        LoggerService.d("请输入歌曲ID");
        return "请输入歌曲ID";
      } else if (sid == asid) {
        LoggerService.d("已经匹配成功，无需再次匹配。");
        return "已经匹配成功，无需再次匹配。";
      }

      if (await checkCloudFileStatus(sid)) {
        int songStatus = await checkSongStatus(asid);
        if (songStatus == 1) {
          String apiUrl =
              "https://music.163.com/api/cloud/user/song/match?userId=$uid&songId=$sid&adjustSongId=$asid";

          final response = await HttpService.getHtml(
            apiUrl,
            cookie: UserService().cookies,
          );
          if (response != null && response.data != null) {
            Map<String, dynamic> jsonData = HashMap();
            if (response.data is String) {
              // 解析JSON
              jsonData = json.decode(response.data);
            } else if (response.data is Map<String, dynamic>) {
              jsonData = response.data;
            }
            if (jsonData['code']?.toString() == '200') {
              LoggerService.d("匹配纠正成功！");
              return "匹配纠正成功！";
            } else {
              LoggerService.d("匹配纠正失败！");
              return "匹配纠正失败！";
            }
          }
        } else if (songStatus == 0) {
          LoggerService.d("输入的歌曲ID不存在");
          return "输入的歌曲ID不存在";
        }
      } else {
        LoggerService.d("云盘文件不存在");
        return "云盘文件不存在";
      }
    } catch (e) {
      LoggerService.d(e.toString());
      return "未知错误";
    }
    return "未知错误";
  }

  Future<List<Song>> searchSong(String filename) async {
    List<Song> songs = [];
    if (filename.isEmpty) {
      return songs;
    }
    try {
      final title = p.basenameWithoutExtension(filename);
      String apiUrl =
          "https://music.163.com/api/search/pc?type=1&offset=0&limit=100&s=\"$title\"";

      final response = await HttpService.getHtml(
        apiUrl,
        cookie: UserService().cookies,
      );
      if (response != null && response.data != null) {
        Map<String, dynamic> jsonData = HashMap();
        if (response.data is String) {
          // 解析JSON
          jsonData = json.decode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        }
        if (jsonData['code']?.toString() == '200' &&
            jsonData['result'] != null &&
            jsonData['result']['songs'] != null &&
            jsonData['result']['songs'].isNotEmpty) {
          final data = jsonData['result']['songs'] as List<dynamic>;
          final songList =
              data.map((songData) => Song.fromMap(songData)).toList();
          songs.addAll(songList);
          return songs;
        }
      }
    } catch (e) {
      LoggerService.d(e.toString());
    }
    return songs;
  }
}
