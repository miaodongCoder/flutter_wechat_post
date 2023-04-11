class VideoModel {
  String? cover;
  String? url;

  VideoModel({this.cover, this.url});

  VideoModel.fromJson(Map<String, dynamic> json) {
    if (json["cover"] is String) {
      cover = json["cover"];
    }
    if (json["url"] is String) {
      url = json["url"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["cover"] = cover;
    data["url"] = url;
    return data;
  }
}
