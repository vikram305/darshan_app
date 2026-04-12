import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_routes.dart';

class ApiService {
  late final Dio _dio;

  ApiService(this._dio) {
    _initApiService();
  }

  _initApiService() {
    _dio.options = BaseOptions(
      baseUrl: ApiRoutes.baseUrl,
      responseType: ResponseType.json,
      contentType: 'application/json',
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 1),
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    );
    addInterceptors();
  }

  addInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Response> get(String endUrl, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(endUrl, queryParameters: queryParameters);
  }

  Future<Response> post(String endUrl, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(endUrl, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String endUrl, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(endUrl, data: data, queryParameters: queryParameters);
  }
}
