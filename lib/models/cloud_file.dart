class CloudFile {
  String songId;
  String fileName;
  String fileSize;
  String addTime;
  String name;
  String artist;

  CloudFile(
    this.songId,
    this.fileName,
    this.fileSize,
    this.addTime,
    this.name,
    this.artist,
  );

  // 从 Map 创建 Song 实例
  factory CloudFile.fromMap(Map<String, dynamic> map) {
    return CloudFile(
      map['songId'].toString(),
      map['fileName'].toString(),
      map['fileSize'].toString(),
      map['addTime'].toString(),
      map['songName'].toString(),
      map['artist'].toString(),
    );
  }
}
