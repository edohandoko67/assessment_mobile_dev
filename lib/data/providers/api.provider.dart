import 'package:dio/dio.dart' as dio;
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response;

import '../../routes/routes.dart';
import '../../utils/log.dart';
import '../../utils/storage.dart';
import 'cache.provider.dart';

class HttpClient {
  HttpClient({
    required this.baseUrl,
    this.enableCache = false,
    this.showAlert = true,
    this.duration = const Duration(seconds: 15),
  });

  final String baseUrl;
  final bool enableCache;
  final bool showAlert;
  final Duration duration;
  final Storage _storage = Storage();

  late dio.Dio dioClient = dio.Dio(dio.BaseOptions(baseUrl: baseUrl))
    ..interceptors.addAll([
      dio.LogInterceptor(
        responseHeader: false,
        error: true,
        responseBody: true,
        requestHeader: false,
      ),
      if (enableCache)
        DioCacheInterceptor(
          options: CacheOptions(
            store: HiveCacheStore(AppPathProvider.path),
            policy: CachePolicy.forceCache,
            hitCacheOnErrorExcept: [],
            maxStale: duration,
            priority: CachePriority.high,
          ),
        ),
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final String? token = _storage.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (dio.DioError e, dio.ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _refreshAccessToken();

            if (refreshed) {
              final newToken = _storage.getToken();
              e.requestOptions.headers["Authorization"] = "Bearer $newToken";

              try {
                final retryResponse = await dioClient.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (err) {
                return handler.reject(err as dio.DioError);
              }
            } else {
              _storage.logout();
              _storage.saveToken('');
              _storage.saveRefreshToken('');
              Get.offAllNamed(Routes.LOGIN);
            }
          }

          switch (e.type) {
            case dio.DioErrorType.connectTimeout:
            case dio.DioErrorType.sendTimeout:
            case dio.DioErrorType.receiveTimeout:
              if (showAlert) EasyLoading.dismiss();
              break;
            case dio.DioErrorType.response:
              if (showAlert) EasyLoading.showError(
                  e.response?.statusMessage ?? "Server Error");
              break;
            case dio.DioErrorType.cancel:
              if (showAlert) EasyLoading.dismiss();
              break;
            case dio.DioErrorType.other:
              if (showAlert) EasyLoading.showError(
                  "Terjadi Kesalahan pada server!");
              break;
          }
          Log.d(e);
          return handler.next(e);
        },
      )
    ]);

  Future<bool> _refreshAccessToken() async {
    final refreshToken = _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await dioClient.post(
        "${baseUrl}auth/refresh",
        data: {"refreshToken": refreshToken},
      );

      final newAccessToken = response.data["accessToken"];
      final newRefreshToken = response.data["refreshToken"];

      if (newAccessToken != null && newRefreshToken != null) {
        _storage.saveToken(newAccessToken);
        _storage.saveRefreshToken(newRefreshToken);
        Log.d("Token berhasil diperbarui otomatis");
        return true;
      }
    } catch (err) {
      Log.d("Gagal refresh token: $err");
    }

    return false;
  }

  Future<dio.Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
        void Function(int, int)? onReceiveProgress,
      }) async {
    dio.Response<T> response = await dioClient.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    dio.Options requestOptions = (options ?? dio.Options()).copyWith(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_storage.getToken()}',
      },
    );
    print('token: Bearer ${_storage.getToken()}');

    return response;
  }

  Future<dio.Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        bool showError = true,
        bool useFormData = false,
        bool followRedirects = false,
      }) async {
    dynamic requestData = data;
    if (useFormData && data is Map<String, dynamic>) {
      requestData = dio.FormData.fromMap(data);
    }

    dio.Options requestOptions = (options ?? dio.Options()).copyWith(
      followRedirects: followRedirects,
      headers: {
        'Content-Type':
        useFormData ? 'multipart/form-data' : 'application/json',
        'Authorization': 'Bearer ${_storage.getToken()}',
      },
    );
    print('token: Bearer ${_storage.getToken()}');

    try {
      dio.Response<T> response = await dioClient.post(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on dio.DioError catch (e) {
      if (showError) {
        print('Dio Error: ${e.message}');
        print('Response Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (showError) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  Future<dio.Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        dio.Options? options,
        dio.CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
        bool showError = true,
      }) async {
    dio.Options requestOptions = (options ?? dio.Options()).copyWith(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_storage.getToken()}',
      },
    );
    print('token: Bearer ${_storage.getToken()}');

    try {
      dio.Response<T> response = await dioClient.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response;
    } on dio.DioError catch (e) {
      if (showError) {
        print('Dio PUT Error: ${e.message}');
        print('Response Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (showError) {
        print('Error: $e');
      }
      rethrow;
    }
  }

  Future<dio.Response<T>> delete<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        dynamic data,
        dio.Options? options,
        dio.CancelToken? cancelToken,
        bool showError = true,
      }) async {
    dio.Options requestOptions = (options ?? dio.Options()).copyWith(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_storage.getToken()}',
      },
    );
    print('token: Bearer ${_storage.getToken()}');

    try {
      dio.Response<T> response = await dioClient.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      return response;
    } on dio.DioError catch (e) {
      if (showError) {
        print('Dio DELETE Error: ${e.message}');
        print('Response Error: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      if (showError) {
        print('Error: $e');
      }
      rethrow;
    }
  }

}
