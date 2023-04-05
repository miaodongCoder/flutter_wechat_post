// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// 视频播放器:
/// 1.压缩视频, 显示进度;
/// 2.播放压缩后的视频文件;
class VideoPlayerWidget extends StatefulWidget {
  // chewie 视频播放器控制器:
  final ChewieController? controller;
  // 视频 asset:
  final AssetEntity? initAsset;
  // 视频完成压缩的回调方法:
  final Function(CompressMediaFile file)? onCompletion;

  const VideoPlayerWidget({
    super.key,
    this.controller,
    this.initAsset,
    this.onCompletion,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  // video 视频控制器:
  VideoPlayerController? _videoController;
  // chewie控制器:
  ChewieController? _controller;
  // 压缩消息订阅(可以监听进度百分比):
  Subscription? _subscription;
  // 资源 asset:
  AssetEntity? _asset;
  // 是否载入中:
  bool _isLoading = false;
  // 是否错误:
  bool _isError = false;
  // 压缩进度:
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _asset = widget.initAsset;
    // 压缩进度订阅:
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      debugPrint('progress = $progress');
      setState(() {
        _progress = progress;
      });
    });
    // 资源树渲染完成:
    if (mounted) {
      onLoad();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _controller?.dispose();
    VideoCompress.cancelCompression();
    _subscription?.unsubscribe();
    _subscription = null;
    VideoCompress.deleteAllCache();

    super.dispose();
  }

  Future<File> getFile() async {
    var file = await _asset?.file;
    if (file == null) throw 'file is null';

    return file;
  }

  void onLoad() async {
    // 初始界面状态:
    setState(() {
      _isLoading = (_asset != null);
      _isError = (_asset == null);
    });

    // 安全检查:
    if (_asset == null) return;
    // 清理资源, 释放播放器对象:
    _videoController?.dispose();
    // 视频压缩操作:
    try {
      File file = await getFile();
      CompressMediaFile result = await DuCompress.video(file);
      File? videoFile = result.video.file;
      if (videoFile == null) {
        debugPrint('videoFile = null !');
        return;
      }
      /**
       * 我最终还是用的chewie视频播放控制器, 但是初始化chewie的过程中需要原生的video_player控制器的一些支持,
       * 所以我先初始化原生的video_player , 同时我把我要播放的file文件传递到原生video_player中初始化好!
       **/
      // video_player初始化:
      _videoController = VideoPlayerController.file(videoFile);
      await _videoController?.initialize();
      // chewie初始化:
      _controller = widget.controller ??
          ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: false,
            autoInitialize: true,
            showOptions: false,
            cupertinoProgressColors: ChewieProgressColors(
              playedColor: accentColor,
            ),
            materialProgressColors: ChewieProgressColors(
              playedColor: accentColor,
            ),
            allowPlaybackSpeedChanging: false,
            deviceOrientationsOnEnterFullScreen: [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
              DeviceOrientation.portraitUp,
            ],
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.portraitUp,
            ],
          );
      if (widget.onCompletion != null) {
        widget.onCompletion!(result);
      }
    } catch (error) {
      print('$error');
      DuToast.show('Video File Error!');
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mainView(context);
  }

  Widget _mainView(BuildContext context) {
    Widget ws = const SizedBox.shrink();
    // 加载中:
    if (_isLoading) {
      ws = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            ' 压缩进度: ${_progress.toStringAsFixed(2)}% ',
            style: const TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      );
    }
    // 正确显示:
    else {
      if (_controller != null && !_isError) {
        ws = Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
        );
      }
    }

    // 返回 `16:9` 的按比例包裹组件:
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[100],
        child: ws,
      ),
    );
  }
}
