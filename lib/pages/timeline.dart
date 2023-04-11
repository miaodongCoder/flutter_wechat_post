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

class _TimeLinePageState extends State<TimeLinePage> {
  // 用户资料:
  UserModel? _user;
  // 时间线:
  List<TimelineModel> _items = [];
  // 滚动控制器:
  final ScrollController _scrollController = ScrollController();
  Color? _appBarColor;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 200) {
        _appBarColor = Colors.black87;
      } else {
        _appBarColor = null;
      }
      setState(() {});
    });

    _user = UserModel(
      uid: "0000",
      nickname: "小苗晓雪~",
      avator:
          "http://n.sinaimg.cn/translate/274/w937h937/20181121/w3_3-hnyuqhi6990881.jpg",
      cover: "images/flower.png",
    );

    _loadData();
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
        backgroundColor: _appBarColor,
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

  Widget? _buildListItem(TimelineModel item) {
    int imgCount = item.images?.length ?? 0;
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
              // 2.正文:
              Text(
                item.content ?? "",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SpaceVerticalWidget(),
              // 3.九宫格图片:
              // 动态计算用LayoutBuilder:
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double imgWidth = imgCount == 1
                      ? constraints.maxWidth * 0.7
                      : imgCount == 2
                          ? (constraints.maxWidth -
                                  spacing * 2 -
                                  imagePadding * 1 * 2) /
                              2
                          : (constraints.maxWidth -
                                  spacing * 2 -
                                  imagePadding * 2 * 3) /
                              3;
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
              // 5.时间:
              Text(
                item.publishDate ?? "",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SpaceVerticalWidget(),
            ],
          ),
        ),
      ],
    );
  }

  // 发布事件:
  void _onPublish() async {
    final selectedAssets =
        await DuBottomSheet().wxPicker<List<AssetEntity>>(context);
    if (selectedAssets == null || selectedAssets.isEmpty || !mounted) return;
    // 把输入的内容压入界面:
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PostEditPage(
            postType: (selectedAssets.length == 1 &&
                    selectedAssets.first.type == AssetType.video)
                ? PostType.video
                : PostType.image,
            selectedAssets: selectedAssets,
          );
        },
      ),
    );
  }
}
