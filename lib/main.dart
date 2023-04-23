import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/global.dart';
import 'pages/index.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TimeLinePage(),
      navigatorObservers: [
        Global.routeObserver,
      ],
    );
  }
}
