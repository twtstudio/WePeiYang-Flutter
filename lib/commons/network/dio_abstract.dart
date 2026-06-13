part of 'wpy_dio.dart';

/// [OnSuccess]和[OnResult]均为请求成功；[OnFailure]为请求失败
typedef OnSuccess = void Function();
typedef OnResult<T> = void Function(T data);
typedef OnFailure = void Function(DioException e);

// TODO: 是否考虑删除 abstract ，这样有些简单使用的地方就不用再继承一个类了？
abstract class DioAbstract {
  String baseUrl = '';
  Map<String, String>? headers;
  List<Interceptor> interceptors = [];
  InterceptorsWrapper? errorInterceptor = null;
  ResponseType responseType = ResponseType.json;
  bool SSL = true;

  late final Dio _dio;

  late final Dio _dio_debug;

  DioAbstract() {
    BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        responseType: responseType,
        headers: headers,
        validateStatus: (status) => status! < 400);

    _dio = Dio(options);
    if (!SSL) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        var client = HttpClient();
        // 设置为信任所有证书
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }
    // 不要删除！！！！
    // 配置 fiddler 代理
    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (HttpClient client) {
    //   client.findProxy = (uri) {
    //     //proxy all request to localhost:8888
    //     return 'PROXY 127.0.0.1:8888';
    //   };
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };
    _dio.interceptors.addAll([
      NetCheckInterceptor(),
      // 精简网络日志：默认一行（method + url + status + 耗时），出错才带 error 详情。
      TalkerDioLogger(
        talker: appTalker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: false,
          printResponseHeaders: false,
          printRequestData: false,
          printResponseData: false,
          printResponseMessage: false,
          printErrorData: true,
          printResponseTime: true,
        ),
      ),
      ...interceptors,
      errorInterceptor ?? ErrorInterceptor()
    ]);

    _dio_debug = Dio(options);
    _dio_debug.interceptors.addAll([
      NetCheckInterceptor(),
      // 调试用 dio：打全量 request / response body 与 headers。
      TalkerDioLogger(
        talker: appTalker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printRequestData: true,
          printResponseData: true,
          printResponseTime: true,
        ),
      ),
      ...interceptors,
      errorInterceptor ?? ErrorInterceptor()
    ]);
  }
}

extension DioRequests on DioAbstract {
  /// 普通的[get]、[post]、[put]与[download]方法，返回[Response]
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      bool debug = false}) {
    return retry(
      // Make a GET request
      () => (debug ? _dio_debug : _dio)
          .get(path, queryParameters: queryParameters, options: options)
          .catchError((error, stack) {
        Log.e(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> post(String path,
      {Map<String, dynamic>? queryParameters,
      FormData? formData,
      data,
      Options? options,
      bool debug = false}) {
    return retry(
      () => (debug ? _dio_debug : _dio)
          .post(path,
              queryParameters: queryParameters,
              data: formData ?? data,
              options: options)
          .catchError((error, stack) {
        Log.e(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> put(String path,
      {Map<String, dynamic>? queryParameters, bool debug = false}) {
    return retry(
      () => (debug ? _dio_debug : _dio)
          .put(path, queryParameters: queryParameters)
          .catchError((error, stack) {
        Log.e(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> delete(String path,
      {Map<String, dynamic>? queryParameters,
      data,
      Options? options,
      bool debug = false}) {
    return retry(
      () => (debug ? _dio_debug : _dio)
          .delete(path,
              queryParameters: queryParameters,
              data: data,
              options: options)
          .catchError((error, stack) {
        Log.e(error, stack);
        throw error;
      }),
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }

  Future<Response<dynamic>> download(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress,
      Options? options,
      bool debug = false}) {
    return retry(
      () => (debug ? _dio_debug : _dio)
          .download(urlPath, savePath,
              onReceiveProgress: onReceiveProgress, options: options)
          .catchError((error, stack) {
        Log.e(error, stack);
        throw error;
      }),
      // Retry on SocketException or TimeoutException
      retryIf: (e) => e is SocketException || e is TimeoutException,
      maxAttempts: 3,
    );
  }
}
