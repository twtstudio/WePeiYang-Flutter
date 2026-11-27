import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_ohos/flutter_inappwebview_ohos.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart'
    as ark;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class WpyOhosWebView extends WebViewPlatform {
  static void registerWith() {
    WebViewPlatform.instance = WpyOhosWebView();
  }

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) =>
      _Controller(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) =>
      _NavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) =>
      _WebViewWidget(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(PlatformWebViewControllerCreationParams params)
      : super.implementation(params);

  final initial = ValueNotifier<LoadRequestParams?>(null);
  final channels = <String, JavaScriptChannelParams>{};
  bool javascript = false;
  ark.PlatformInAppWebViewController? view;
  _NavigationDelegate? navigation;

  ark.URLRequest request(LoadRequestParams params) => ark.URLRequest(
        url: ark.WebUri.uri(params.uri),
        method: params.method.name.toUpperCase(),
        headers: params.headers,
        body: params.body,
      );

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    if (!const ['http', 'https'].contains(params.uri.scheme) ||
        params.uri.host.isEmpty) {
      throw ArgumentError.value(params.uri, 'uri', 'Expected HTTP(S)');
    }
    final controller = view;
    if (controller == null) {
      initial.value = params;
    } else {
      await controller.loadUrl(urlRequest: request(params));
    }
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {
    javascript = mode == JavaScriptMode.unrestricted;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate delegate,
  ) async {
    navigation = delegate as _NavigationDelegate;
  }

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {
    channels[params.name] = params;
  }

  @override
  Future<void> removeJavaScriptChannel(String name) async {
    channels.remove(name);
    view?.removeJavaScriptHandler(handlerName: name);
  }

  @override
  Future<bool> canGoBack() async => await view?.canGoBack() ?? false;

  @override
  Future<void> goBack() async {
    await view?.goBack();
  }
}

class _NavigationDelegate extends PlatformNavigationDelegate {
  _NavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params);

  PageEventCallback? onPageStarted;
  PageEventCallback? onPageFinished;
  WebResourceErrorCallback? onError;

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {
    onPageStarted = callback;
  }

  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    onPageFinished = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {
    onError = callback;
  }
}

class _WebViewWidget extends PlatformWebViewWidget {
  _WebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) =>
      _ArkWebView(controller: params.controller as _Controller);
}

class _ArkWebView extends StatefulWidget {
  const _ArkWebView({required this.controller});

  final _Controller controller;

  @override
  State<_ArkWebView> createState() => _ArkWebViewState();
}

class _ArkWebViewState extends State<_ArkWebView> {
  static final _random = Random.secure();
  // 每个视图使用独立令牌，回调同时校验令牌和当前页面来源。
  final _token = base64UrlEncode(
    List<int>.generate(24, (_) => _random.nextInt(256)),
  );
  OhosInAppWebViewWidget? _platformView;

  @override
  void dispose() {
    widget.controller.view = null;
    _platformView?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ValueListenableBuilder<LoadRequestParams?>(
      valueListenable: controller.initial,
      builder: (context, params, _) {
        if (params == null) return const SizedBox.expand();
        final uri = params.uri;
        final origins = [
          uri.origin,
          if (uri.scheme == 'http' && uri.port == 80)
            Uri(scheme: 'https', host: uri.host).origin,
        ];
        _platformView ??=
            OhosInAppWebViewWidget(ark.PlatformInAppWebViewWidgetCreationParams(
          layoutDirection: Directionality.of(context),
          initialUrlRequest: controller.request(params),
          initialSettings: ark.InAppWebViewSettings(
            javaScriptEnabled: controller.javascript,
          ),
          initialUserScripts: UnmodifiableListView([
            for (final name in controller.channels.keys)
              ark.UserScript(
                source: '''
                  if (window.top === window && ${jsonEncode(origins)}.includes(window.location.origin)) {
                    window[${jsonEncode(name)}] = {
                      postMessage: function(value) {
                        window.flutter_inappwebview.callHandler(
                          ${jsonEncode(name)}, ${jsonEncode(_token)}, String(value));
                      }
                    };
                  }
                ''',
                injectionTime: ark.UserScriptInjectionTime.AT_DOCUMENT_START,
                forMainFrameOnly: true,
              ),
          ]),
          onWebViewCreated: (view) {
            controller.view = view;
            for (final name in controller.channels.keys) {
              view.addJavaScriptHandler(
                  handlerName: name,
                  callback: (args) async {
                    final url = await view.getUrl();
                    if (url != null &&
                        (url.scheme == 'http' || url.scheme == 'https') &&
                        origins.contains(url.origin) &&
                        args.length == 2 &&
                        args.first == _token &&
                        args.last is String) {
                      controller.channels[name]?.onMessageReceived(
                        JavaScriptMessage(message: args.last as String),
                      );
                    }
                    return null;
                  });
            }
          },
          onLoadStart: (_, url) =>
              controller.navigation?.onPageStarted?.call(url?.toString() ?? ''),
          onLoadStop: (_, url) => controller.navigation?.onPageFinished
              ?.call(url?.toString() ?? ''),
          onReceivedError: (_, request, error) {
            if (request.isForMainFrame != false) {
              controller.navigation?.onError?.call(WebResourceError(
                errorCode: error.type.toNativeValue() ?? -1,
                description: error.description,
                isForMainFrame: request.isForMainFrame,
                url: request.url.toString(),
              ));
            }
          },
        ));
        return _platformView!.build(context);
      },
    );
  }
}
