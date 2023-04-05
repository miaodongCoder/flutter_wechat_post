import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';

class CompressMediaFile {
  // 缩略图:
  final File thumbnail;
  // 媒体文件:
  final MediaInfo video;
  CompressMediaFile({
    required this.thumbnail,
    required this.video,
  });
}

class DuCompress {
  /// 压缩图片:
  static Future<File?> image(
    File file, {
    int minWidth = 1920,
    int minHeight = 1080,
  }) async {
    String targetPath = '${file.path}_temp.jpg';
    return FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      keepExif: true,
      quality: 80,
      format: CompressFormat.jpeg,
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }

  /// 压缩视频:
  static Future<CompressMediaFile> video(File file) async {
    // 分别拿到thumbnail和realVideo才行:
    var result = await Future.wait([
      VideoCompress.getFileThumbnail(
        file.path,
        quality: 80,
        position: -1000,
      ),
      VideoCompress.compressVideo(
        file.path, quality: VideoQuality.Res640x480Quality,
        // 默认不要去删除原视频:
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 25,
      ),
    ]);

    return CompressMediaFile(
      thumbnail: result.first as File,
      video: result.last as MediaInfo,
    );
  }

  /// 清理缓存:
  static Future<bool?> clean() async {
    return await VideoCompress.deleteAllCache();
  }

  /// 取消:
  static Future<void> cancel() async {
    return await VideoCompress.cancelCompression();
  }
// // 清理缓存
//   static Future<bool?> clean() async {
//     return await VideoCompress.deleteAllCache();
//   }

//   // 取消
//   static Future<void> cancel() async {
//     await VideoCompress.cancelCompression();
//   }
}
