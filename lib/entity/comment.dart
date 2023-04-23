import 'index.dart';

class CommentModel {
  UserModel? user;
  String? content;
  String? publishDate;

  CommentModel({this.user, this.content, this.publishDate});

  CommentModel.fromJson(Map<String, dynamic> json) {
    user = json["user"] == null ? null : UserModel.fromJson(json["user"]);
    content = json["content"];
    publishDate = json["publishDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data["user"] = user?.toJson();
    }
    data["content"] = content;
    data["publishDate"] = publishDate;
    return data;
  }
}
