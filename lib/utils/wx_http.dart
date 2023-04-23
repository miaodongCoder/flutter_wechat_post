import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wechat_post/utils/index.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class WxHttpUtil {
  static final WxHttpUtil _instance = WxHttpUtil._internal();
  factory WxHttpUtil() => _instance;
  Dio? _dio;
  WxHttpUtil._internal() {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 5),
        headers: {},
        contentType: 'application/json; chaeset=utf-8',
        responseType: ResponseType.json,
      ),
    ).addPrettyPrint;
  }

  /// Get请求:
  Future<Response> get(String url, {Map<String, dynamic>? data}) async {
    // get请求其实是一个查询方法 , 所以这里 (queryParameters: data)~
    return await _dio!.get(url, queryParameters: data);
  }

  /// Post请求:
  Future<Response> post(String url, {Map<String, dynamic>? data}) async {
    return await _dio!.post(url, data: data);
  }
}

// 扩展Dio 为它添加分类方法 自定义logger输出:
extension AddPrettyPrint on Dio {
  Dio get addPrettyPrint {
    interceptors.add(
      PrettyDioLogger(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
        compact: false,
        maxWidth: 100,
        logPrint: (object) {
          debugPrint("$object");
        },
      ),
    );

    return this;
  }
}
