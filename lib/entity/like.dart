class LikeModel {
  String? uid;
  String? nickname;
  String? avator;

  LikeModel({this.uid, this.nickname, this.avator});

  LikeModel.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    nickname = json["nickname"];
    avator = json["avator"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["uid"] = uid;
    data["nickname"] = nickname;
    data["avator"] = avator;
    return data;
  }
}
