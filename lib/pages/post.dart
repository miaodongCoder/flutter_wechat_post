import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/config.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage({super.key});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  // 选择的图片数组:
  List<AssetEntity> selectedAssets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发布"),
      ),
      body: _mainView(),
    );
  }

  Widget _mainView() {
    return Column(
      children: [
        // 九宫格图片列表:
        _buildPhotoList(),
      ],
    );
  }

  // 构建图片列表:
  Widget _buildPhotoList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = (constraints.maxWidth - spacing * 2) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              // 1.图片:
              for (AssetEntity asset in selectedAssets)
                _buildPhotoItems(asset, width),
              // 2.按钮:
              if (selectedAssets.length < maxAssets)
                _buildAddButton(context, width),
            ],
          );
        },
      ),
    );
  }

  // 图片项:
  Container _buildPhotoItems(AssetEntity asset, double width) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: AssetEntityImage(
        asset,
        width: width,
        height: width,
        fit: BoxFit.cover,
        isOriginal: false,
      ),
    );
  }

  // 添加图片按钮:
  GestureDetector _buildAddButton(BuildContext context, double width) {
    return GestureDetector(
      onTap: () async {
        final List<AssetEntity>? assets = await AssetPicker.pickAssets(
          context,
          pickerConfig: AssetPickerConfig(
            selectedAssets: selectedAssets,
            maxAssets: maxAssets,
          ),
        );

        // 拿到图片:
        setState(() {
          selectedAssets = assets ?? [];
        });
      },
      child: Container(
        color: Colors.black12,
        width: width,
        height: width,
        child: const Icon(
          Icons.add,
          size: 48,
          color: Colors.black45,
        ),
      ),
    );
  }
}
