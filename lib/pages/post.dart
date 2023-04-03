import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/config.dart';
import 'package:flutter_wechat_post/widgets/gallery.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PostEditPage extends StatefulWidget {
  const PostEditPage({super.key});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  // 选择的图片数组:
  List<AssetEntity> selectedAssets = [];
  // 是否开始拖拽:
  bool isDragNow = false;
  // 是否将要删除:
  bool isWillRemove = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发布"),
      ),
      body: _mainView(),
      // 底部工具栏 Scaffold 脚手架已经帮忙做好了 , 只要设置显示与否的条件即可:
      bottomSheet: isDragNow ? _buildRemoveBar() : null,
    );
  }

  Widget _mainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 九宫格图片列表:
        _buildPhotoList(),
        // if (isDragNow) _buildRemoveBar() else const SizedBox.shrink(),
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
  Widget _buildPhotoItems(AssetEntity asset, double width) {
    return Draggable<AssetEntity>(
      data: asset,
      onDragStarted: () {
        setState(() {
          isDragNow = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          isDragNow = false;
        });
      },
      // 被dragTarget对象接收:
      onDragCompleted: () {},
      // 被dragTarget对象拒绝或者主动松手放弃:
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          isDragNow = false;
        });
      },
      // 拖拽的时候显示在指针下方的小组件:
      feedback: _getImageItem(asset, width),
      // 拖拽的时候原位置的图片样式:
      childWhenDragging: _getImageItem(asset, width,
          opacity: const AlwaysStoppedAnimation(.2)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return GalleryWidget(
                  initialindex: selectedAssets.indexOf(asset),
                  items: selectedAssets,
                  isBarVisible: false,
                );
              },
            ),
          );
        },
        child: _getImageItem(asset, width),
      ),
    );
  }

  /// 每一个小图片方块视图的样式:
  Container _getImageItem(AssetEntity asset, double width,
      {Animation<double>? opacity}) {
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
        opacity: opacity,
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

        // 空安全检查:
        if (assets == null || assets.isEmpty) return;
        // 拿到图片:
        setState(() {
          selectedAssets = assets.toList();
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

  /// 删除Bar:
  Widget _buildRemoveBar() {
    return DragTarget<AssetEntity>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 130,
          width: MediaQuery.of(context).size.width,
          color: isWillRemove ? Colors.red[500] : Colors.red[200],
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.delete,
              size: 32,
              color: Colors.white70,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "拖拽到这里删除",
              style: TextStyle(
                color: isWillRemove ? Colors.white : Colors.white70,
              ),
            ),
          ]),
        );
      },
      onWillAccept: (data) {
        setState(() {
          isWillRemove = true;
        });
        return true;
      },
      onAccept: (data) {
        setState(() {
          selectedAssets.remove(data);
          isWillRemove = false;
        });
      },
      onLeave: (data) {
        setState(() {
          isWillRemove = false;
        });
      },
    );
  }
}
