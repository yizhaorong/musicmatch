class Song {
  String songId;
  String songName;
  String artist;
  String album;
  String coverUrl;
  String songUrl;
  String duration;

  Song(
    this.songId,
    this.songName,
    this.artist,
    this.album,
    this.coverUrl,
    this.songUrl,
    this.duration,
  );
  // 从 Map 创建 Song 实例
  factory Song.fromMap(Map<String, dynamic> map) {
    var artists = map['artists'];
    String artist = '';
    if (artists is List && artists.isNotEmpty) {
      var firstArtist = artists[0];
      artist = firstArtist['name'];
    }
    var album = map['album'];
    var coverUrl = '';
    var albumName = '';
    if (album is Map) {
      albumName = album['name'];
      coverUrl = album['picUrl'];
    } else {
      albumName = '未知';
    }
    return Song(
      map['id'].toString(),
      map['name'].toString(),
      artist,
      albumName.toString(),
      coverUrl.toString(),
      map['mp3Url'].toString(),
      map['duration'].toString(),
    );
  }
}
