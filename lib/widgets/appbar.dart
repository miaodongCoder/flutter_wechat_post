import 'package:flutter/material.dart';

/// 本类为 `AppBar` 的弹出与收起的动画:
class SliderAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final AnimationController controller;
  final bool visible;
  const SliderAppBarWidget({
    super.key,
    required this.child,
    required this.controller,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    // 定义一个区间:
    final Tween<Offset> tween = Tween<Offset>(
      begin: Offset.zero,
      // 结束为止是y轴收起到-1 位置:
      end: const Offset(0, -1),
    );

    // 执行区间动画:
    final Animation<Offset> position = tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    return SlideTransition(
      position: position,
      child: child,
    );
  }

  @override
  Size get preferredSize {
    return child.preferredSize;
  }
}
