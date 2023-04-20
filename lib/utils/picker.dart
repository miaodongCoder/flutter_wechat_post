// 相册选取:
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/config.dart';
import 'package:flutter_wechat_post/widgets/camera/camera.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class DuPicker {
  // 1.相册选取:
  static Future<List<AssetEntity>?> assets({
    required BuildContext context,
    List<AssetEntity>? selectedAssets,
    int maxAssets = maxAssets,
    // 默认图片:
    RequestType requestType = RequestType.image,
  }) async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        selectedAssets: selectedAssets,
        requestType: requestType,
        maxAssets: maxAssets,
      ),
    );
    return assets;
  }

  // 2.拍摄照片:
  static Future<AssetEntity?> takePhoto(BuildContext context) async {
    return _getPictureWithCaptureMode(context, CaptureMode.photo);
  }

  // 3.拍摄视频:
  static Future<AssetEntity?> takeVideo(BuildContext context) async {
    return _getPictureWithCaptureMode(context, CaptureMode.video);
  }

  // 拍摄的私有方法:
  static Future<AssetEntity?> _getPictureWithCaptureMode(BuildContext context, CaptureMode captureMode) async {
    final result = await Navigator.of(context).push<AssetEntity?>(MaterialPageRoute(builder: (context) {
      return CameraPage(
        captureMode: captureMode,
      );
    }));
    return result;
  }

  /// 底部弹出框:
  static Future<T?> showModalSheet<T>(
    BuildContext context, {
    Widget? child,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: child,
        );
      },
    );
  }
}
