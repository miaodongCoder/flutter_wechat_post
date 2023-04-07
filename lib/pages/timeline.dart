import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/pages/index.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({super.key});

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainView(context),
    );
  }

  Widget _mainView(BuildContext context) {
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
  }
}
