import 'dart:async';

import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  // 倒计时长
  final Duration time;

  // 结束回调
  final Function callback;
  const Countdown({
    super.key,
    required this.time,
    required this.callback,
  });

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  late Duration _currentTime;
  @override
  void initState() {
    super.initState();
    _currentTime = widget.time;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newTime = _currentTime - const Duration(seconds: 1);
      if (newTime == Duration.zero) {
        widget.callback();
        _timer.cancel();
      } else {
        setState(() {
          _currentTime = newTime;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_currentTime.inSeconds}s',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 30.0,
      ),
    );
  }
}
