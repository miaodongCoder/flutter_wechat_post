/// 将[TextSpan]树 绘制到[Canvas]中的对象.

import 'package:flutter/material.dart';

class TextMaxLinesWidget extends StatefulWidget {
  final String content;
  final int? maxLines;
  const TextMaxLinesWidget({super.key, required this.content, this.maxLines});

  @override
  State<TextMaxLinesWidget> createState() => _TextMaxLinesWidgetState();
}

class _TextMaxLinesWidgetState extends State<TextMaxLinesWidget> {
  late String _content;
  late int _maxLines;
  bool _isExpand = false;

  @override
  void initState() {
    super.initState();

    _content = widget.content;
    _maxLines = widget.maxLines ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return _mainView();
  }

  Widget _mainView() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 将[TextSpan]树 绘制到[Canvas]中的对象.
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: _content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          maxLines: _maxLines,
          textDirection: TextDirection.ltr,
        )..layout(
            maxWidth: constraints.maxWidth,
          );

        // 1.不展开:
        if (_isExpand == false) {
          List<Widget> ws = [];
          // 超出_maxLins行, 展示 `_maxLins行内容 + 全文`:
          if (textPainter.didExceedMaxLines) {
            // 添加三行文字:
            ws.add(
              Text(
                _content,
                maxLines: _maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            );
            // 全文:
            ws.add(
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpand = !_isExpand;
                  });
                },
                child: _buildGestureWidget("展开..."),
              ),
            );
          }
          // 不超出_maxLins行展示全文:
          else {
            ws.add(
              Text(
                _content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ws,
          );
        }
        // 2.展开显示全部内容:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpand = !_isExpand;
                });
              },
              child: _buildGestureWidget("收起"),
            )
          ],
        );
      },
    );
  }

  Text _buildGestureWidget(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, color: Colors.blue),
    );
  }
}
