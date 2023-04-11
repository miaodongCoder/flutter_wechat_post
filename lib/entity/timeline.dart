import 'package:flutter_wechat_post/entity/index.dart';

/// 朋友圈动态数据:
class TimelineModel {
  String? id;
  List<String>? images;
  VideoModel? video;
  String? content;
  String? postType;
  UserModel? user;
  String? publishDate;
  String? location;

  TimelineModel(
      {this.id,
      this.images,
      this.video,
      this.content,
      this.postType,
      this.user,
      this.publishDate,
      this.location});

  TimelineModel.fromJson(Map<String, dynamic> json) {
    if (json["id"] is String) {
      id = json["id"];
    }
    if (json["images"] is List) {
      images =
          json["images"] == null ? null : List<String>.from(json["images"]);
    }
    if (json["video"] is Map) {
      video = json["video"] == null ? null : VideoModel.fromJson(json["video"]);
    }
    if (json["content"] is String) {
      content = json["content"];
    }
    if (json["post_type"] is String) {
      postType = json["post_type"];
    }
    if (json["user"] is Map) {
      user = json["user"] == null ? null : UserModel.fromJson(json["user"]);
    }
    if (json["publishDate"] is String) {
      publishDate = json["publishDate"];
    }
    if (json["location"] is String) {
      location = json["location"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    if (images != null) {
      data["images"] = images;
    }
    if (video != null) {
      data["video"] = video?.toJson();
    }
    data["content"] = content;
    data["post_type"] = postType;
    if (user != null) {
      data["user"] = user?.toJson();
    }
    data["publishDate"] = publishDate;
    data["location"] = location;
    return data;
  }
}
