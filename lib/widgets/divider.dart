import 'package:flutter/material.dart';

/// 分隔条:
class DividerWidget extends StatelessWidget {
  final double? height;
  const DividerWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      color: Colors.grey[100],
    );
  }
}
