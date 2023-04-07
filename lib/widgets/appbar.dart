import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  // 填充色:
  final Color? backgroundColor;
  // appbar下方的阴影大小:
  final double? elevation;
  // 返回按钮:
  final Widget? leading;
  // 右侧的按钮组:
  final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return _mainView(context);
  }

  AppBar _mainView(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      leading: leading,
      actions: actions,
    );
  }
}
