import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final VoidCallback? onUnauthorized;

  AuthInterceptor(this._storageService, {this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        print('🔒 [401 Unauthorized] Session expired. Triggering logout.');
      }
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

class AppLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🌐 [HTTP ${options.method}] ${options.uri}');
      if (options.data != null) {
        print('   Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('✅ [HTTP ${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('❌ [HTTP ERROR ${err.response?.statusCode}] ${err.requestOptions.uri}');
      print('   Details: ${err.response?.data ?? err.message}');
    }
    handler.next(err);
  }
}
