import 'package:flutter_wechat_post/entity/index.dart';
import 'package:flutter_wechat_post/utils/index.dart';

/// 朋友圈列表:
class TimelineApi {
  /// 分页数据:
  static Future<List<TimelineModel>> pageList() async {
    var result = await WxHttpUtil().get(
      'timeline/news',
    );
    List<TimelineModel> list = [];
    for (var item in result.data) {
      list.add(TimelineModel.fromJson(item));
    }
    return list;
  }

  /// 点赞:
  static Future like(String id) async {
    var result = await WxHttpUtil().post(
      'timeline/$id/like',
    );
    return result;
  }

  // 评论接口:
  static Future comment(String id, String content) async {
    var result = await WxHttpUtil().post(
      'timeline/$id/comment',
      data: {
        'content': content,
      },
    );
    return result;
  }
}
