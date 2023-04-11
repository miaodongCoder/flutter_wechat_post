class UserModel {
  String? uid;
  String? nickname;
  String? avator;
  String? cover;

  UserModel({this.uid, this.nickname, this.avator, this.cover});

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json["uid"] is String) {
      uid = json["uid"];
    }
    if (json["nickname"] is String) {
      nickname = json["nickname"];
    }
    if (json["avator"] is String) {
      avator = json["avator"];
    }
    if (json["cover"] is String) {
      avator = json["cover"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["uid"] = uid;
    data["nickname"] = nickname;
    data["avator"] = avator;
    data["cover"] = cover;

    return data;
  }
}
