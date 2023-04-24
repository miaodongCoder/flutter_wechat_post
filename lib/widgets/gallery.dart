// ignore_for_file: avoid_print

import 'package:chewie/chewie.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wechat_post/entity/index.dart';
import 'package:flutter_wechat_post/global.dart';
import 'package:flutter_wechat_post/styles/text.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:flutter_wechat_post/widgets/index.dart';
import 'package:flutter_wechat_post/widgets/space.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum GalleryType {
  assets,
  urls,
  video,
}

// 图像浏览器:
class GalleryWidget extends StatefulWidget {
  // 初始图片位置:
  final int initialIndex;
  // 图片列表:
  final List<AssetEntity> items;
  // 是否显示顶部的导航栏条:
  final bool? isBarVisible;
  // 动态信息:
  final TimelineModel? timeline;
  final List<String>? imgUrls;
  const GalleryWidget({
    super.key,
    required this.initialIndex,
    required this.items,
    this.isBarVisible,
    this.timeline,
    this.imgUrls,
  });

  @override
  State<GalleryWidget> createState() => _GalleryWidgetState();
}

/* SingleTickerProviderStateMixin 防止界面外动画 */
class _GalleryWidgetState extends State<GalleryWidget>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  bool visible = true;
  // 动画控制器:
  late final AnimationController controller;
  bool _isShowAppBar = true;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  // 预览类型:
  GalleryType _galleryType = GalleryType.assets;
  // 当前页码:
  int _currentPage = 0;

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

    // 是否显示Bar:
    _isShowAppBar = widget.isBarVisible ?? true;
    // 将给定对象注册为绑定观察者.捆绑 当各种应用程序事件发生时,观察者会收到通知,例如:当系统区域设置更改时:
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoadVideo());

    // 阅览类型:
    if (widget.timeline?.postType == '2') {
      _galleryType = GalleryType.video;
    } else if (widget.imgUrls != null) {
      _galleryType = GalleryType.urls;
    } else if (widget.items.isNotEmpty) {
      _galleryType = GalleryType.assets;
    }
    // 当前页码
    _currentPage = widget.initialIndex + 1;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print("didChangeAppLifecycleState $state");
    if (_videoController?.value.isInitialized != true) return;
    if (state != AppLifecycleState.paused) _chewieController?.pause();
    if (state != AppLifecycleState.resumed) _chewieController?.play();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    Global.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Global.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  // RouteAware的方法:
  // 监控4个路由事件的回调方法:
  @override
  void didPush() {
    super.didPush();
    print('didPush');
  }

  @override
  void didPushNext() {
    super.didPushNext();
    print('didPushNext');
    if (_videoController?.value.isInitialized != true) return;
    _chewieController?.pause();
  }

  @override
  void didPop() {
    super.didPop();
    print('didPop');
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print('didPopNext');
    if (_videoController?.value.isInitialized != true) return;
    _chewieController?.play();
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  Widget _mainView() {
    Widget body = const Text("loading...");
    // 数量:
    int itemsCount = widget.items.length;
    if (itemsCount == 0) itemsCount = widget.imgUrls?.length ?? 0;

    switch (_galleryType) {
      case GalleryType.assets:
        body = _buildImageView();
        break;
      case GalleryType.video:
        body = _buildVideoView();
        break;
      case GalleryType.urls:
        body = _buildImageByUrlsView();
        break;
      default:
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _isShowAppBar = !_isShowAppBar;
      }),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        // appBar: SliderAppBarWidget(
        //   controller: controller,
        //   visible: visible,
        //   child: AppBarWidget(
        //     isAnimated: true,
        //     isShow: _isShowAppBar,
        //     leading: GestureDetector(
        //       onTap: () => Navigator.pop(context),
        //       child: const Icon(
        //         Icons.arrow_back_ios_outlined,
        //         color: Colors.white,
        //       ),
        //     ),
        //     actions: [
        //       GestureDetector(
        //         onTap: () {
        //           // 导航压入新页面:
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) {
        //                 return Scaffold(
        //                   appBar: AppBar(
        //                     title: const Text(
        //                       "新页面",
        //                     ),
        //                   ),
        //                   body: const Center(
        //                     child: Text(
        //                       "新页面",
        //                     ),
        //                   ),
        //                 );
        //               },
        //             ),
        //           );
        //         },
        //         child: const Padding(
        //           padding: EdgeInsets.only(
        //             right: pagePadding,
        //           ),
        //           child: Icon(
        //             Icons.more_horiz_outlined,
        //             color: Colors.white,
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        appBar: _galleryType == GalleryType.assets ? _buildPublishNav(itemsCount) : _buildPreviewNav(itemsCount),
        body: body,
        bottomSheet: _buildTimeLineBar(_isShowAppBar),
      ),
    );
  }

  Widget _buildImageView() {
    return ExtendedImageGesturePageView.builder(
      controller: ExtendedPageController(
        initialPage: widget.initialIndex,
      ),
      itemCount: widget.items.length,
      onPageChanged: (int index) {
        print("翻页: 第 $index 页~");
        setState(() {
          _currentPage = index + 1;
        });
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

  // 初始加载视频:
  Future<void> _onLoadVideo() async {
    if (widget.timeline?.postType != '2') {
      return Future.value();
    }

    try {
      // videoPlayer 初始化:
      _videoController = VideoPlayerController.network(widget.timeline?.video?.url ?? "");
      await _videoController?.initialize();
      // chewie 初始化:
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        autoInitialize: true,
        showOptions: false,
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: accentColor,
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: accentColor,
        ),
        // 是否允许显示播放速度控件:
        allowPlaybackSpeedChanging: false,
        // 进入全屏允许设备的方向:
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
        ],
        // 退出全屏后允许设备的方向集:
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        placeholder: _videoController?.value.isInitialized != true
            ? Image.network(DuTools.imageUrlFormat(widget.timeline?.video?.cover ?? ""))
            : null,
      );
    } catch (e) {
      DuToast.show('Video url load error: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  // 视频视图:
  Widget _buildVideoView() {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: (_chewieController == null)
                ? Text(
                    "视频载入中 loading ...",
                    style: textStyleDetail,
                    textAlign: TextAlign.center,
                  )
                : Chewie(
                    controller: _chewieController!,
                  ),
          ),
        ),
      ),
    );
  }

  /// 动态栏:
  Widget? _buildTimeLineBar(bool isShow) {
    TimelineModel? timelineModel = widget.timeline;
    // 喜欢数量:
    int likeCount = timelineModel?.likes?.length ?? 0;
    // 评论数量:
    int commentsCount = timelineModel?.comments?.length ?? 0;
    if (!isShow || timelineModel == null) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(spacing),
          child: Text(
            timelineModel.content ?? "",
            style: textStyleDetail,
          ),
        ),

        // 点赞数、评论、详情:
        Container(
          padding: const EdgeInsets.only(left: spacing, right: spacing, top: spacing, bottom: spacing * 2),
          color: Colors.black,
          child: Row(
            children: [
              // like图标:
              if (likeCount > 0)
                const Icon(
                  Icons.favorite_border_outlined,
                  size: 23,
                  color: Colors.white,
                ),

              const SpaceHorizontalWidget(),
              if (likeCount > 0)
                Text(
                  "$likeCount",
                  style: textStyleDetail,
                ),
              const SpaceHorizontalWidget(),

              // 评论图标:
              if (commentsCount > 0)
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 24,
                  color: Colors.white,
                ),
              const SpaceHorizontalWidget(),
              // 评论文字:
              if (commentsCount > 0)
                Text(
                  "$commentsCount",
                  style: textStyleDetail,
                ),
              const Spacer(),
              // 详情按钮:
              GestureDetector(
                onTap: () {},
                child: Text(
                  "详情 >",
                  style: textStyleDetail,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // URL 图片视图
  Widget _buildImageByUrlsView() {
    return ExtendedImageGesturePageView.builder(
      onPageChanged: (int index) {
        setState(() {
          _currentPage = index + 1;
        });
      },
      controller: ExtendedPageController(
        initialPage: widget.initialIndex,
      ),
      itemCount: widget.imgUrls?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final String src = widget.imgUrls![index];
        return ExtendedImage(
          image: ExtendedNetworkImageProvider(DuTools.imageUrlFormat(src, width: 700)),
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

  // 导航栏 - 选相册:
  AppBarWidget _buildPublishNav(int pages) {
    return AppBarWidget(
      isAnimated: true,
      isShow: _isShowAppBar,
      title: Text(
        "$_currentPage / $pages",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.white,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: pagePadding),
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("发布"),
          ),
        ),
      ],
    );
  }

  // 导航栏 - 图片 url 列表:
  AppBarWidget _buildPreviewNav(int pages) {
    return AppBarWidget(
      isAnimated: true,
      isShow: _isShowAppBar,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 日期
          Text(
            widget.timeline?.publishDate ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          // 页码页数
          if (widget.timeline?.postType == "1")
            Text(
              "$_currentPage / $pages",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
        ],
      ),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios_outlined,
          color: Colors.white,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // 导航压入新界面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text("新界面"),
                    ),
                    body: const Center(
                      child: Text("新界面"),
                    ),
                  );
                },
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.only(right: pagePadding),
            child: Icon(
              Icons.more_horiz_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
