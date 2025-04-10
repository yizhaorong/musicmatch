class CloudInfo {
  String size;
  String maxSize;
  CloudInfo({required this.size, required this.maxSize});
  factory CloudInfo.fromJson(Map<String, dynamic> json) {
    return CloudInfo(
      size: json['size'].toString(),
      maxSize: json['maxSize'].toString(),
    );
  }
}
