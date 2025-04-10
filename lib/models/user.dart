class User {
  String userId;
  String nickname;
  String avatarUrl; // 头像 URL

  User(this.userId, this.nickname, this.avatarUrl);

  static User fromJson(Map<String, dynamic> userProfile) {
    return User(
      userProfile['userId'].toString(),
      userProfile['nickname'].toString(),
      userProfile['avatarUrl'].toString(),
    );
  }
}
