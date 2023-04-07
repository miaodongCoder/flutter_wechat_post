// ignore_for_file: avoid_print

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/widgets/slider_appbar.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// 图像浏览器:
class GalleryWidget extends StatefulWidget {
  // 初始图片位置:
  final int initialindex;
  // 图片列表:
  final List<AssetEntity> items;
  // 是否显示顶部的导航栏条:
  final bool? isBarVisible;
  const GalleryWidget({
    super.key,
    required this.initialindex,
    required this.items,
    this.isBarVisible,
  });

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

/* SingleTickerProviderStateMixin 防止界面外动画 */
class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin {
  bool visible = true;
  // 动画控制器:
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    visible = widget.isBarVisible ?? false;
    controller = AnimationController(
      // 混入: SingleTickerProviderStateMixin这里才能this:
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  Widget _mainView() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SliderAppBarWidget(
        controller: controller,
        visible: visible,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        // 不允许穿透:
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            visible = !visible;
          });
        },
        child: _buildImageView(),
      ),
    );
  }

  Widget _buildImageView() {
    return ExtendedImageGesturePageView.builder(
      controller: ExtendedPageController(
        initialPage: widget.initialindex,
      ),
      itemCount: widget.items.length,
      onPageChanged: (int index) {
        print("翻页: 第 $index 页~");
      },
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final AssetEntity item = widget.items[index];
        return ExtendedImage(
          image: AssetEntityImageProvider(
            item,
          ),
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: true,
            );
          },
        );
      },
    );
  }
}
