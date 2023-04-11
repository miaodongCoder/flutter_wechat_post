import 'package:flutter/material.dart';

class SpaceHorizontalWidget extends StatelessWidget {
  final double? width;
  const SpaceHorizontalWidget({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width ?? 10);
  }
}

class SpaceVerticalWidget extends StatelessWidget {
  final double? height;
  const SpaceVerticalWidget({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height ?? 10);
  }
}
