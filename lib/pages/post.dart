// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:flutter_wechat_post/widgets/gallery.dart';
import 'package:flutter_wechat_post/widgets/player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum PostType {
  image,
  video,
}

/// 发布界面:
class PostEditPage extends StatefulWidget {
  // 发布类型:
  final PostType postType;
  final List<AssetEntity>? selectedAssets;
  const PostEditPage({super.key, required this.postType, this.selectedAssets});

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
  // 选择的图片数组:
  List<AssetEntity> _selectedAssets = [];
  // 是否开始拖拽:
  bool _isDragNow = false;
  // 是否将要删除:
  bool _isWillRemove = false;
  // 是否将要排序:
  bool _isWillOrder = false;
  // 被拖拽到的 target id:
  String targetId = "";
  // 发布类型:
  PostType? _postType;
  // 视频压缩文件:
  CompressMediaFile? _videoCompressFile;

  @override
  void initState() {
    super.initState();

    _postType = widget.postType;
    _selectedAssets = widget.selectedAssets ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发布"),
      ),
      body: _mainView(),
      // 底部工具栏 Scaffold 脚手架已经帮忙做好了 , 只要设置显示与否的条件即可:
      bottomSheet: _isDragNow ? _buildRemoveBar() : null,
    );
  }

  Widget _mainView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 九宫格图片列表:
        if (_postType == PostType.image) _buildPhotoList(),
        if (_postType == PostType.video)
          VideoPlayerWidget(
            initAsset: _selectedAssets.first,
            onCompletion: (file) {
              _videoCompressFile = file;
            },
          ),
        if (_postType == null && _selectedAssets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(spacing),
            child: _buildAddButton(context, 130),
          ),
      ],
    );
  }

  // 构建图片列表:
  Widget _buildPhotoList() {
    return Padding(
      padding: const EdgeInsets.all(spacing),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width =
              (constraints.maxWidth - spacing * 2 - imagePadding * 2 * 3) / 3;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              // 1.图片:
              for (AssetEntity asset in _selectedAssets)
                _buildPhotoItems(asset, width),
              // 2.按钮:
              if (_selectedAssets.length < maxAssets)
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
          _isDragNow = true;
        });
      },
      // 当可拖动对象被放下时:
      onDragEnd: (details) {
        setState(() {
          _isDragNow = false;
          _isWillOrder = false;
        });
      },
      // 被dragTarget对象接收:
      onDragCompleted: () {},
      // 被dragTarget对象拒绝或者主动松手放弃:
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _isDragNow = false;
        });
      },
      // 拖拽的时候显示在指针下方的小组件:
      feedback: _getImageItem(asset, width),
      // 拖拽的时候原位置的图片样式:
      childWhenDragging: _getImageItem(
        asset,
        width,
        opacity: const AlwaysStoppedAnimation(.2),
      ),
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GalleryWidget(
                      initialindex: _selectedAssets.indexOf(asset),
                      items: _selectedAssets,
                      isBarVisible: false,
                    );
                  },
                ),
              );
            },
            child: _getImageItem(asset, width),
          );
        },
        // 将要被排序:
        onWillAccept: (data) {
          setState(() {
            _isWillOrder = true;
            // 赋值图片ID:
            targetId = asset.id;
          });
          return true;
        },
        onAccept: (AssetEntity data) {
          // data为被拖拽的图片、asset为目标图片:
          // 交换数组中的两个元素的位置:
          final int index = _selectedAssets.indexOf(data);
          final targetIndex = _selectedAssets.indexOf(asset);
          _selectedAssets[index] = _selectedAssets[targetIndex];
          _selectedAssets[targetIndex] = data;

          setState(() {
            // 重置排序判断:
            _isWillOrder = false;
            // 重置图片ID:
            targetId = "";
          });
        },
        onLeave: (data) {
          setState(() {
            _isWillOrder = false;
            targetId = "";
          });
        },
      ),
    );
  }

  /// 每一个小图片方块视图的样式:
  Padding _getImageItem(AssetEntity asset, double width,
      {Animation<double>? opacity}) {
    return Padding(
      padding: (_isWillOrder && targetId == asset.id)
          ? EdgeInsets.zero
          : const EdgeInsets.all(imagePadding),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: (_isWillOrder && targetId == asset.id)
              ? Border.all(color: accentColor, width: imagePadding)
              : null,
        ),
        child: AssetEntityImage(
          asset,
          width: width,
          height: width,
          fit: BoxFit.cover,
          isOriginal: false,
          opacity: opacity,
        ),
      ),
    );
  }

  // 添加图片按钮:
  Widget _buildAddButton(BuildContext context, double width) {
    return GestureDetector(
      onTap: () async {
        final result = await DuBottomSheet(selectedAssets: _selectedAssets)
            .wxPicker<List<AssetEntity>>(context);
        if (result == null || result.isEmpty) return;
        // 视频:
        if (result.length == 1 && result.first.type == AssetType.video) {
          _postType = PostType.video;
        }
        //图片:
        else {
          _postType = PostType.image;
        }
        setState(() {
          _selectedAssets = result;
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
          color: _isWillRemove ? Colors.red[500] : Colors.red[200],
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
                color: _isWillRemove ? Colors.white : Colors.white70,
              ),
            ),
          ]),
        );
      },
      onWillAccept: (data) {
        setState(() {
          _isWillRemove = true;
        });
        return true;
      },
      onAccept: (data) {
        setState(() {
          _selectedAssets.remove(data);
          _isWillRemove = false;
        });
      },
      onLeave: (data) {
        setState(() {
          _isWillRemove = false;
        });
      },
    );
  }
}
