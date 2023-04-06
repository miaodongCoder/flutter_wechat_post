import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/config.dart' as config;
import 'package:flutter_wechat_post/widgets/camera/take_photo.dart';
import 'package:flutter_wechat_post/widgets/camera/take_vide.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraPage extends StatelessWidget {
  /// 拍照、拍视频:
  final CaptureMode captureMode;

  /// 视频最大时长:
  final Duration? maxVideoDuration;
  const CameraPage({
    super.key,
    required this.captureMode,
    this.maxVideoDuration = const Duration(seconds: config.maxVideoDuration),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        saveConfig: captureMode == CaptureMode.photo
            ? SaveConfig.photo(pathBuilder: _buildFilePath)
            : SaveConfig.video(pathBuilder: _buildFilePath),
        builder: (cameraState, previewSize, rect) {
          return cameraState.when(
            // 拍照:
            onPhotoMode: (state) => TakePhotoPage(state),
            // 拍视频:
            onVideoMode: (state) => TakeVideoPage(
              state,
              maxVideoDuration: maxVideoDuration,
            ),
            // 拍摄中:
            onVideoRecordingMode: (state) => TakeVideoPage(
              state,
              maxVideoDuration: maxVideoDuration,
            ),
            // 启动摄像头:
            onPreparingCamera: (state) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        // 生成规则:
        imageAnalysisConfig: AnalysisConfig(),
        // 经纬度:
        exifPreferences: ExifPreferences(
          saveGPSLocation: false,
        ),
      ),
    );
  }

  // 生成文件路径
  Future<String> _buildFilePath() async {
    // 获取临时文件夹:
    final extDir = await getTemporaryDirectory();
    // 扩展名:
    final extenName = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';
    return '${extDir.path}/${const Uuid().v4()}.$extenName';
  }
}
