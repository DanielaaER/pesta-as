import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'app.dart';
import 'explorer.dart';

class Pestana {
  final String name;
  final String url;
  final String uniqueId;
  late WebViewController controller;
  static final WebviewCookieManager globalCookieManager =
      WebviewCookieManager();
  late List<WebViewCookie> cookies;

  Pestana({required this.name, required this.url, required this.uniqueId});
}

class ViewPage extends StatefulWidget {
  final Pestana page;

  ViewPage({required this.page});

  @override
  ViewPageState createState() => ViewPageState();
}

class ViewPageState extends State<ViewPage> {
  late WebViewController _controller;
  late final CookieManager? cookieManager;
  bool step = true;
  late final WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    cargarCookies();
    cargar();
    // widget.page.loadCookies(); // Cargar cookies al iniciar
  }

  @override
  void dispose() {
    saveCookies(); // Guardar cookies al salir
    super.dispose();
  }

  void cargar() async {
    setState(() {
      step = false;
    });
    print("step ${step}");
    await cargarCookies();

    setState(() {
      step = true;
    });

    print("step ${step}");
  }

  @override
  Widget build(BuildContext context) {
    // if (step) {
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
                    clearCookies();

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
                    clearCookies();

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
      body: WebView(
        initialUrl: widget.page.url,
        javascriptMode: JavascriptMode.unrestricted,
        debuggingEnabled: true,
        // initialCookies: widget.page.cookies,
        onWebViewCreated: (WebViewController webViewController) {
          cargarCookies();
          print('onWebViewCreated llamado');
          _controller = webViewController;

          widget.page.controller = webViewController;
        },
        onPageFinished: (String url) {
          getCookies();
        },

      ),
    );
    // } else {
    //   return Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
  }

  Future<void> saveCookies() async {
    try {
      final cookies = await _getCookies() ?? '';
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          '${widget.page.uniqueId}_cookies_${widget.page.name}', [cookies]);
      print("save cookies");
      print("${widget.page.uniqueId}_cookies_${widget.page.name}");
      print(cookies);
    } catch (error) {
      if (kDebugMode) {
        print("Error al guardar las cookies: $error");
      }
    }
  }

  Future<void> clearCookies() async {
    var cookies = await _getCookies() ?? '';
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        '${widget.page.uniqueId}_cookies_${widget.page.name}', [cookies]);
    print("save cookies");
    print("${widget.page.uniqueId}_cookies_${widget.page.name}");
    print(cookies);

    print("clear in save");
    WebviewCookieManager().clearCookies();
    print("cookies limpias");
    cookies = await _getCookies() ?? '';
    print(cookies);
  }

  Future<String?> _getCookies() async {
    print("get cookies");
    String cookies = await _controller.evaluateJavascript('document.cookie');

    List<String> cookieList = cookies.split(';').map((e) => e.trim()).toList();

    print("en get" + cookies);
    return cookies;
  }

  Future<List<WebViewCookie>> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final cookiesStringList = prefs.getStringList(
            '${widget.page.uniqueId}_cookies_${widget.page.name}') ??
        [];
    print('${widget.page.uniqueId}_cookies_${widget.page.name}');
    print("cargo lista");
    print(cookiesStringList);
    List<WebViewCookie> cookies = [];

    for (String cookiesString in cookiesStringList) {
      List<String> cookiesList = cookiesString.split("; ");

      for (String cookieString in cookiesList) {
        List<String> cookieParts = cookieString.split('=');

        if (cookieParts.length == 2) {
          String nombre = cookieParts[0].trim();
          String valor = cookieParts[1].trim();
          print("nombre: " + nombre);
          print("valor: " + valor);

          WebViewCookie webViewCookie = WebViewCookie(
            name: nombre,
            value: valor,
            domain: widget.page.url,
          );
          await CookieManager().setCookie(
            WebViewCookie(
              name: nombre,
              value: valor,
              domain: widget.page.url,
            ),
          );
          String cookie = '$nombre=$valor; path=/; domain=${widget.page.url}';
          await _controller.evaluateJavascript('document.cookie = "$cookie";');

          cookies.add(webViewCookie);
          final gcook = await _getCookies() ?? '';
          print("agregue una? " + gcook);

          // await webViewController.loadRequest(Uri.parse(
          //   'https://httpbin.org/anything',
          // ));
        }

      }
    }

    print(cookies);
    return cookies;
  }

  Future<void> cargarCookies() async {
    List<WebViewCookie> listaCookies = await getCookies();

    await _controller.loadUrl(widget.page.url);
    print("estoy cargando cookies");
    print(listaCookies);
    widget.page.cookies = listaCookies;
    _getCookies();
  }
}
