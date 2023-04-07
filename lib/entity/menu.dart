import 'package:flutter/material.dart';

class MenuItemModel {
  // 图标:
  final IconData? icon;
  // 标题:
  final String? title;
  // 右侧菜单名称:
  final String? right;
  // 点击事件:
  final Function()? onTap;

  MenuItemModel({
    this.icon,
    this.title,
    this.right,
    this.onTap,
  });
}
