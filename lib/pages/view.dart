import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports


import 'app.dart';
import 'explorer.dart';

class Pestana {
  final String name;
  final String url;
  final String uniqueId;
  late WebViewController controller;
  static final WebviewCookieManager _globalCookieManager = WebviewCookieManager();

  Pestana({required this.name, required this.url})
      : uniqueId = UniqueKey().toString();

  Future<void> saveCookies() async {
    try {
      final cookies = await _getCookies() ?? '';
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('${uniqueId}_cookies_$name', [cookies]);
    } catch (error) {
      if (kDebugMode) {
        print("Error al guardar las cookies: $error");
      }
    }
  }

  Future<void> loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookiesStringList = prefs.getStringList('${uniqueId}_cookies_$name');
    
    if (cookiesStringList != null) {
      final cookies = cookiesStringList.map((cookieString) => Cookie.fromSetCookieValue(cookieString)).toList();
      await _globalCookieManager.setCookies(cookies, origin: url);
    }
  }

  Future<String?> _getCookies() async {
    final cookies = await _globalCookieManager.getCookies(url) ?? [];
    return cookies.isEmpty ? null : cookies.map((cookie) => cookie.toString()).join(';');
  }
}

class ViewPage extends StatefulWidget {
  final Pestana page;

  ViewPage({required this.page});

  @override
  ViewPageState createState() => ViewPageState();
}

class ViewPageState extends State<ViewPage> {
  late WebViewController _controller;
  final cookieManager = WebviewCookieManager();


  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse("${widget.page.url}"));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        title: Container(
          child: Row(
            children: [
              Container(
                alignment: AlignmentDirectional.centerStart,
                width: MediaQuery.of(context).size.width * .72,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.transparent,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    fixedSize: Size(MediaQuery.of(context).size.width * .65, 1),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExplorerScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "${widget.page.name}",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * .2,
                alignment: AlignmentDirectional.centerEnd,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    onPrimary: Colors.black,
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * .00001,
                      MediaQuery.of(context).size.height * .001,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppScreen(),
                      ),
                    );
                  },
                  child: Text("+"),
                ),
              )
            ],
          ),
        ),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
