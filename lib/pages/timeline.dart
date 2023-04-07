import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/entity/index.dart';
import 'package:flutter_wechat_post/pages/index.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:flutter_wechat_post/widgets/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  UserModel? _user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarWidget(
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

  @override
  void initState() {
    super.initState();

    _user = UserModel(
      nickName: "贾玥",
      avator:
          "http://n.sinaimg.cn/translate/274/w937h937/20181121/w3_3-hnyuqhi6990881.jpg",
      cover:
          "http://n.sinaimg.cn/translate/560/w1080h1080/20181121/8yD0-hnyuqhi6991083.jpg",
    );
  }

  Widget _mainView() {
    return Column(
      children: [
        _buildHeader(),
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

  // 头部组件抽取:
  Widget _buildHeader() {
    final double width = MediaQuery.of(context).size.width;
    return _user == null
        ? const SizedBox.square()
        : Stack(
            alignment: Alignment.bottomRight,
            children: [
              // 背景:
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child: ExtendedImage.network(
                    _user?.cover ?? "",
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
                  // 昵称
                  Text(
                    _user?.nickName ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 18,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 10,
                          ),
                        ]),
                  ),
                  const SizedBox(width: 10),
                  // 头像:
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: ExtendedImage.network(
                      _user?.avator ?? "",
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

  void _onPublish() async {
    final selectedAssets =
        await DuBottomSheet().wxPicker<List<AssetEntity>>(context);
    if (selectedAssets == null || selectedAssets.isEmpty) return;
    // 把输入的内容压入界面:
    if (mounted) {
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
}
