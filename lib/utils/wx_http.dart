import 'package:dio/dio.dart';
import 'package:flutter_wechat_post/utils/index.dart';

class WxHttpUtil {
  static final WxHttpUtil _instance = WxHttpUtil._internal();
  factory WxHttpUtil() => _instance;
  Dio? _dio;
  WxHttpUtil._internal() {
    if (_dio == null) {
      _dio = Dio();
      _dio?.options = BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 5),
        headers: {},
        contentType: 'application/json; chaeset=utf-8',
        responseType: ResponseType.json,
      );
    }
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
