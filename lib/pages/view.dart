import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'app.dart';
import 'explorer.dart';

class Pestana {
  final String name;
  final String url;
  final String uniqueId;
  late WebViewController controller;
  static final WebviewCookieManager _globalCookieManager =
  WebviewCookieManager();
  late final WebViewCookieManager cookieManager = WebViewCookieManager();

  Pestana({required this.name, required this.url, required this.uniqueId});

  Future<void> saveCookies() async {
    try {
      final cookies = await _getCookies() ?? '';
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('${uniqueId}_cookies_$name', [cookies]);
      print("save cookies");
      print("${uniqueId}_cookies_$name");
      print(cookies);

      print("clear in save");
      _globalCookieManager.clearCookies();
    } catch (error) {
      if (kDebugMode) {
        print("Error al guardar las cookies: $error");
      }
    }
  }

  Future<void> loadCookies() async {
    // await _globalCookieManager.clearCookies();
    // print("clear cookie in load");
    final prefs = await SharedPreferences.getInstance();
    final cookiesStringList = prefs.getStringList('${uniqueId}_cookies_$name');
    print("load cookie");
    print("${uniqueId}_cookies_$name");
    print(cookiesStringList);
    if (cookiesStringList != null) {
      print("coookk");
      for (String cookiesString in cookiesStringList) {
        // Dividir la cadena de cookies en cookies individuales
        List<String> cookiesList = cookiesString.split("; ");

        for (String cookieString in cookiesList) {
          // Dividir cada cookie en nombre y valor
          List<String> cookieParts = cookieString.split('=');

          if (cookieParts.length == 2) {
            String nombre = cookieParts[0].trim();
            String valor = cookieParts[1].trim();
            print("nombre: " + nombre);
            print("valor: " + valor);

            await cookieManager.setCookie(
              WebViewCookie(
                name: nombre,
                value: valor,
                domain: url,
                path: '/',
              ),
            );
          }
        }
      }
    }
    _getCookies();

  }

  Future<String?> _getCookies() async {
    print("get cookies");
    // String cookies = await WebViewController().runJavaScriptReturningResult('document.cookie') as String;
    //
    // print(cookies);
    // return cookies;
    final cookies = await _globalCookieManager.getCookies(url) ?? [];
    print(cookies);
    final String cookie = await WebViewController()
        .runJavaScriptReturningResult('document.cookie') as String;
    print("cookie"+cookie);

    return cookies.isEmpty
        ? null
        : cookies.map((cookie) => cookie.toString()).join(';');
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
  final cookieManager = WebViewCookieManager();



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

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

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

    widget.page.loadCookies(); // Cargar cookies al iniciar
  }

  @override
  void dispose() {
    widget.page.saveCookies(); // Guardar cookies al salir
    super.dispose();
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
                    widget.page.saveCookies();

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
                    widget.page.saveCookies();

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
