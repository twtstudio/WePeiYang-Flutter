import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'view_state.dart';
part 'view_state_list_model.dart';

class ViewStateModel with ChangeNotifier {
  /// 防止页面销毁后,异步任务才完成,导致报错
  bool _disposed = false;

  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  ViewState _viewState;

  /// 根据状态构造
  ///
  /// 子类可以在构造函数指定需要的页面状态
  /// FooModel():super(viewState:ViewState.busy);
  /// viewState = idle but data = empty
  ViewStateModel({ViewState viewState})
      : _viewState = viewState ?? ViewState.idle;

  /// ViewState
  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  /// ViewStateError
  ViewStateError _viewStateError;

  ViewStateError get viewStateError => _viewStateError;

  bool get isBusy => viewState == ViewState.busy;

  bool get isIdle => viewState == ViewState.idle;

  bool get isEmpty => viewState == ViewState.empty;

  bool get isError => viewState == ViewState.error;

  /// set
  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    if (viewState != ViewState.busy) viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  /// [e]分类Error和Exception两种
  /// 这里区分了错误类型。
  void setError(e, stackTrace, {String message}) {
    ViewStateErrorType errorType = ViewStateErrorType.defaultError;

    /// 见 https://github.com/flutterchina/dio/blob/master/README-ZH.md#dioerrortype
    if (e is DioError) {
      if (e.messageType == DioErrorType.connectTimeout ||
          e.messageType == DioErrorType.sendTimeout ||
          e.messageType == DioErrorType.receiveTimeout) {
        // timeout
        errorType = ViewStateErrorType.networkTimeOutError;
        message = e.error;
      } else if (e.messageType == DioErrorType.response) {
        // incorrect status, such as 404, 503...
        message = e.error;
      } else if (e.messageType == DioErrorType.cancel) {
        // to be continue...
        message = e.error;
      } else {
        // dio将原error重新套了一层
        e = e.error;
        message = e.toString();
      }
    }
    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      errorType,
      message: message,
      errorMessage: e.toString(),
    );
    onError(viewStateError);
  }

  /// 自定义错误处理
  void onError(ViewStateError viewStateError) {}

  /// 显示错误消息
  showErrorMessage({String message}) {
    if (viewStateError != null || message != null) {
      if (viewStateError.isNetworkTimeOut) {
        message ??= "";
      } else {
        message ??= viewStateError.message;
      }
      Future.microtask(() {
        Fluttertoast.showToast(
            msg: message,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 15.0);
      });
    }
  }

  @override
  String toString() {
    return 'BaseModel{_viewState: $viewState, _viewStateError: $_viewStateError}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// [e]为错误类型 :可能为 Error , Exception ,String
/// [s]为堆栈信息
printErrorStack(e, s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
  Fluttertoast.showToast(
      msg: e.toString(),
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 15.0);
}
