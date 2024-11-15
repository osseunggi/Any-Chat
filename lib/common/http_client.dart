import 'package:dio/dio.dart';

import '../model/auth.dart';
import './error.dart';
import 'config.dart';

class HttpClient {
  final Dio dio = Dio();
  final String baseUrl = HttpConfig.devUrl;

  HttpClient();

  Future<T> createRequest<T>(Future<T> Function() request) => request.call();

  Map<String, dynamic> optionsHeader() => {'Content-Type': 'application/json'};

  Future<T> get<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.get('$baseUrl$path',
              queryParameters: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> post<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.post('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> put<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.put('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> patch<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.patch('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> delete<T>({required String path, Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          (data) => data as T,
          () => dio.delete('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> Function() request<T>(
          T Function(Map<String, dynamic>) converter, Future<Response> Function() handler) =>
      () => handler().then((result) => converter(result.data)).catchError((error, stackTrace) =>
          error is DioException
              ? throw Error(error, stackTrace: stackTrace, statusCode: error.response?.statusCode)
              : throw Error(error, stackTrace: stackTrace));
}

class SecuredHttpClient extends HttpClient {
  SecuredHttpClient();

  @override
  Map<String, dynamic> optionsHeader() => {
        'Content-Type': 'application/json',
        if (auth != null) 'Authorization': 'Bearer ${auth!.accessToken}'
      };

  @override
  Future<T> createRequest<T>(Future<T> Function() request) => request.call().catchError((e) async {
        if ((e as Error).statusCode == 401) {
          return await this
              .request(
                  (result) => result['data'],
                  () => dio.post('$baseUrl/account/api/auth/access-token',
                      options: Options(headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${auth!.refreshToken}'
                      })))()
              .then((data) async {
            auth = auth!.copyWith(accessToken: data['accessToken']);
            return await request.call();
          });
        } else {
          throw e;
        }
      });
}
