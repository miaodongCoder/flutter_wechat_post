// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../widgets/index.dart';
import 'index.dart';

enum PickType {
  camera,
  asset,
}

/// 微信底部弹出:
class DuBottomSheet {
  final List<AssetEntity>? selectedAssets;
  DuBottomSheet({this.selectedAssets});
  // 选择拍摄、相机资源:
  Future<T?> wxPicker<T>(BuildContext context) {
    return DuPicker.showModalSheet<T>(
      context,
      child: _buildAssetCamera(context),
    );
  }

  /// 相册、相机:
  Widget _buildAssetCamera(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 拍摄:
        _buildButton(
          const Text("拍摄"),
          onTap: () {
            DuPicker.showModalSheet(
              context,
              child: _buildMediaImageVideo(context, pickType: PickType.camera),
            );
          },
        ),
        const DividerWidget(),
        // 相册:
        _buildButton(
          const Text("相册"),
          onTap: () {
            DuPicker.showModalSheet(
              context,
              child: _buildMediaImageVideo(context, pickType: PickType.asset),
            );
          },
        ),
        const DividerWidget(
          height: 6,
        ),
        // 取消:
        _buildButton(
          const Text("取消"),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  /// 图片、视频:
  Widget _buildMediaImageVideo(BuildContext context,
      {required PickType pickType}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图片:
        _buildButton(
          const Text("图片"),
          onTap: () async {
            List<AssetEntity>? result;
            // 从相册选择:
            if (pickType == PickType.asset) {
              result = await DuPicker.assets(
                  context: context,
                  requestType: RequestType.image,
                  selectedAssets: selectedAssets);
            }
            // 拍照:
            else {
              final photo = await DuPicker.takePhoto(context);
              if (photo == null) return;
              // 如果列表中之前没有照片:
              if (selectedAssets == null) {
                result = [photo];
              }
              // 直接添加到列表中:
              else {
                result = [...selectedAssets!, photo];
              }
            }

            _popRoute(context, result: result);
          },
        ),
        const DividerWidget(),
        // 视频:
        _buildButton(
          const Text("视频"),
          onTap: () async {
            // 从相册里选择视频:
            List<AssetEntity>? result;
            if (pickType == PickType.asset) {
              result = await DuPicker.assets(
                context: context,
                requestType: RequestType.video,
                selectedAssets: selectedAssets,
                maxAssets: 1,
              );
            }
            // 拍视频:
            else {
              final AssetEntity? photo = await DuPicker.takePhoto(context);
              if (photo == null) return;
              result = [photo];
            }
            _popRoute(context, result: result);
          },
        ),
        const DividerWidget(
          height: 6,
        ),
        // 取消:
        _buildButton(
          const Text("取消"),
          onTap: () {
            _popRoute(context);
          },
        ),
      ],
    );
  }

  void _popRoute(BuildContext context, {result}) {
    Navigator.pop(context);
    Navigator.pop(context, result);
  }

  InkWell _buildButton(Widget? child, {Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 40,
        child: child,
      ),
    );
  }
}
