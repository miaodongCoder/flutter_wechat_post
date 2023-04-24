import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  // 填充色:
  final Color? backgroundColor;
  // appbar下方的阴影大小:
  final double? elevation;
  // 返回按钮:
  final Widget? leading;
  // 右侧的按钮组:
  final List<Widget>? actions;
  // 是否动画:
  final bool? isAnimated;
  // 是否显示:
  final bool? isShow;

  const AppBarWidget({
    super.key,
    this.title,
    this.backgroundColor,
    this.elevation,
    this.leading,
    this.actions,
    this.isAnimated,
    this.isShow,
  });

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return _mainView(context);
  }

  Widget _mainView(BuildContext context) {
    var appBar = AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading: leading,
      actions: actions,
      foregroundColor: Colors.white,
      title: title,
    );
    // 导航栏进入和离开当前屏幕的动画:
    return (isAnimated == true)
        ? (isShow == true)
            ? FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: appBar,
              )
            : FadeOutUp(
                duration: const Duration(milliseconds: 300),
                child: appBar,
              )
        : appBar;
  }
}
