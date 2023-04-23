import 'index.dart';

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
  bool? isLike;
  List<LikeModel>? likes;
  List<CommentModel>? comments;

  TimelineModel({
    this.id,
    this.images,
    this.video,
    this.content,
    this.postType,
    this.user,
    this.publishDate,
    this.location,
    this.isLike,
    this.likes,
    this.comments,
  });

  TimelineModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    images = json["images"] == null ? null : List<String>.from(json["images"]);
    video = json["video"] == null ? null : VideoModel.fromJson(json["video"]);
    content = json["content"];
    postType = json["post_type"];
    user = json["user"] == null ? null : UserModel.fromJson(json["user"]);
    publishDate = json["publishDate"];
    location = json["location"];
    isLike = json["is_like"];
    likes = json["likes"] == null ? null : (json["likes"] as List).map((e) => LikeModel.fromJson(e)).toList();
    comments =
        json["comments"] == null ? null : (json["comments"] as List).map((e) => CommentModel.fromJson(e)).toList();
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
    data["is_like"] = isLike;
    if (likes != null) {
      data["likes"] = likes?.map((e) => e.toJson()).toList();
    }
    if (comments != null) {
      data["comments"] = comments?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
