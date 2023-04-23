/// 工具函数:
class DuTools {
  // 图片地址格式化:
  static String imageUrlFormat(src, {int? width}) {
    // 阿里 OSS:
    if (src.indexOf("aliyuncs.com") > -1) {
      return src + "?x-oss-process=image/resize,w_${width ?? 150},m_lfit";
    }
    return "";
  }

  static String dateTimeFromat(String? dateStr) {
    if (dateStr == null) return "";
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();
    Duration diff = now.difference(date);
    if (diff.inDays > 0) return "${diff.inDays} 天前";
    if (diff.inHours > 0) return "${diff.inHours} 小时前";
    if (diff.inMinutes > 0) return "${diff.inMinutes} 分钟前";
    return "刚刚";
  }
}
