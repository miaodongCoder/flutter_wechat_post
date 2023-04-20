import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/api/timeline.dart';
import 'package:flutter_wechat_post/entity/index.dart';
import 'package:flutter_wechat_post/pages/index.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:flutter_wechat_post/widgets/index.dart';
import 'package:flutter_wechat_post/widgets/space.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

// mixin防止界面退出后动画还在继续!
class _TimeLinePageState extends State<TimeLinePage> with SingleTickerProviderStateMixin {
  // 用户资料:
  UserModel? _user;
  // 时间线:
  List<TimelineModel> _items = [];
  Text? _title;
  // 层管理:
  OverlayState? _overlayState;
  // 遮罩层:
  OverlayEntry? _overlayEntry;
  // 更多按钮位置 offset:
  Offset _buttonOffset = Offset.zero;
  // 动画控制器:
  late final AnimationController _animationController;
  // 动画本身: (监听的操作放到了动画的`builder`方法里了~)
  late Animation<double> _sizeTween;
  // 滚动控制器:
  final ScrollController _scrollController = ScrollController();
  // 头部appbar的背景色:
  Color? _appBarColor;
  double _elevation = 0;
  // 当前正在操作的cellItem:
  // TimelineModel? _currentItem;
  @override
  void initState() {
    super.initState();

    // 监听滚动控制器:
    _scrollController.addListener(() {
      double pixels = _scrollController.position.pixels;
      if (pixels < 0) pixels = 0;
      if (pixels > 200) {
        double opacity = (pixels - 200) / 100;
        if (opacity < 0.85) {
          _appBarColor = Colors.black.withOpacity(opacity);
        }
        _elevation = 1;
        _title = const Text("朋友圈");
      } else {
        _appBarColor = null;
        if (pixels > 150) {
          _elevation = pixels / 200;
        } else {
          _elevation = 0;
        }
        _title = null;
      }

      setState(() {});
    });

    // 初始化层:
    _overlayState = Overlay.of(context);
    // 初始化动画控制器:
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _sizeTween = Tween(begin: 0.0, end: 160.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _user = UserModel(
      uid: "0000",
      nickname: "小苗晓雪~",
      avator: "http://n.sinaimg.cn/translate/274/w937h937/20181121/w3_3-hnyuqhi6990881.jpg",
      cover: "images/flower.png",
    );

    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future _loadData() async {
    var result = await TimelineApi.pageList();
    if (mounted) {
      setState(() {
        _items = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
        title: _title,
        backgroundColor: _appBarColor,
        elevation: _elevation,
        actions: [
          GestureDetector(
            onTap: _onPublish,
            child: const Padding(
              padding: EdgeInsets.only(
                right: spacing,
              ),
              child: Icon(
                Icons.camera_alt,
              ),
            ),
          )
        ],
      ),
      body: _mainView(),
    );
  }

  Widget _mainView() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildHeader(),
          ),
        ),
        // 数据列表:
        _buildList(),
      ],
    );

    /*
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final result =
              await DuBottomSheet().wxPicker<List<AssetEntity>>(context);
          if (result == null || result.isEmpty) return;
          if (!mounted) return;
          // 把返回的图片数据传入导航中:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return PostEditPage(
                  postType: (result.length == 1 &&
                          result.first.type == AssetType.video)
                      ? PostType.video
                      : PostType.image,
                  selectedAssets: result,
                );
              },
            ),
          );
        },
        child: const Text(
          "发布",
        ),
      ),
    );
    */
  }

  // 头部组件:
  Widget _buildHeader() {
    final double width = MediaQuery.of(context).size.width;
    return _user == null
        ? const SizedBox.square()
        : Stack(
            alignment: Alignment.bottomRight,
            children: [
              // 1.背景图片:
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: Image.asset(
                    "${_user!.cover}",
                    width: width,
                    height: width * 0.75,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 昵称、头像:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2.1昵称:
                  Text(
                    _user!.nickname ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        // 字间距:
                        letterSpacing: 2,
                        fontSize: 18,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 10,
                          ),
                        ]),
                  ),
                  const SizedBox(width: 10),
                  // 2.2头像:
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: ExtendedImage.network(
                      _user!.avator ?? "",
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          );
  }

  // 列表:
  Widget _buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          TimelineModel item = _items.elementAt(index);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildListItem(item),
              ),
              // 底部横线:
              const DividerWidget(),
            ],
          );
        },
        childCount: _items.length,
      ),
    );
  }

  // 列表项:
  Widget? _buildListItem(TimelineModel item) {
    int imgCount = item.images?.length ?? 0;
    GlobalKey buttonKey = GlobalKey();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 圆角头像:
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            item.user?.avator ?? "",
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: spacing),
        // 右侧:
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1.昵称:
              Text(
                item.user?.nickname ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SpaceVerticalWidget(),
              // 2.内容:
              TextMaxLinesWidget(content: item.content ?? ""),
              const SpaceVerticalWidget(),
              // 3.九宫格图片(动态计算用LayoutBuilder):
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double imgWidth = imgCount == 1
                      ? constraints.maxWidth * 0.7
                      : imgCount == 2
                          ? (constraints.maxWidth - spacing * 2 - imagePadding * 1 * 2) / 2
                          : (constraints.maxWidth - spacing * 2 - imagePadding * 2 * 3) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: item.images!.map((path) {
                      return SizedBox(
                        width: imgWidth,
                        height: imgWidth,
                        child: Image.network(
                          DuTools.imageUrlFormat(path),
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SpaceVerticalWidget(),
              // 4.地理位置:
              Text(
                item.location ?? "",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              // 5.时间、更多按钮:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 5.1 时间:
                  Text(
                    item.publishDate ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  // 5.3 更多按钮:
                  GestureDetector(
                    onTap: () {
                      // 获取按钮位置:
                      _getMoreButtonOffset(buttonKey);
                      // 显示遮罩层:
                      _onShowMenu(onTap: _onCloseMenu, item: item);
                    },
                    child: Container(
                      key: buttonKey,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SpaceVerticalWidget(),
            ],
          ),
        ),
      ],
    );
  }

  // 显示菜单:
  void _onShowMenu({Function()? onTap, TimelineModel? item}) {
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(children: [
            // 遮罩:
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: Colors.black.withOpacity(.4),
            ),
            // 菜单:
            AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return Positioned(
                  left: _buttonOffset.dx - _sizeTween.value - 10,
                  top: _buttonOffset.dy - 10,
                  child: SizedBox(
                    width: _sizeTween.value,
                    height: 40,
                    child: _buildIsLikeMenu(item: item),
                  ),
                );
              },
            ),
          ]),
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    if (_overlayEntry == null) return;
    _overlayState?.insert(_overlayEntry!);
  }

  // 是否喜欢菜单:
  Widget _buildIsLikeMenu({TimelineModel? item}) {
    bool? isLike = (item?.isLike == true);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (constraints.maxWidth > 80)
                TextButton.icon(
                  onPressed: () {
                    _onLike(item);
                  },
                  icon: Icon(
                    Icons.favorite,
                    size: 18,
                    color: isLike ? Colors.red : Colors.white,
                  ),
                  label: Text(
                    isLike ? "取消" : "点赞",
                    style: textStylePopMenu,
                  ),
                ),
              if (constraints.maxWidth >= 150)
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    "评论",
                    style: textStylePopMenu,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // 获取更多按钮位置 offset:
  void _getMoreButtonOffset(GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    _buttonOffset = offset;
  }

  // 关闭菜单:
  Future<void> _onCloseMenu() async {
    if (_animationController.status != AnimationStatus.completed) return;
    await _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
  }

  // 发布事件:
  void _onPublish() async {
    final selectedAssets = await DuBottomSheet().wxPicker<List<AssetEntity>>(context);
    if (selectedAssets == null || selectedAssets.isEmpty || !mounted) return;
    // 把输入的内容压入界面:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PostEditPage(
            postType: (selectedAssets.length == 1 && selectedAssets.first.type == AssetType.video) ? PostType.video : PostType.image,
            selectedAssets: selectedAssets,
          );
        },
      ),
    );
  }

  // 点赞操作:
  void _onLike(TimelineModel? item) async {
    if (item == null) return;
    // 这里加不加await都可以 , 因为这是一个很小的接口请求操作, 不要因为这一点的接口响应速度影响用户点赞的流畅度~
    // 但是实际来说我还是觉得这样不合理~因为这既然是一个小接口那基本上不会影响用户的操作 , 如果接口响应失败还要做其它的处理~
    try {
      await TimelineApi.like(item.id!);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        item.isLike = !(item.isLike!);
      });
      Future.delayed(const Duration(milliseconds: 150), () {
        _onCloseMenu();
      });
    }
  }
}
