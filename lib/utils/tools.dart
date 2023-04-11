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
}
