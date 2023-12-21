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
  static final WebviewCookieManager _globalCookieManager =
      WebviewCookieManager();

  Pestana({required this.name, required this.url, required this.uniqueId});

  Future<void> saveCookies() async {
    try {
      final cookies = await _getCookies() ?? '';
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('${uniqueId}_cookies_$name', [cookies]);
      print("save cookies");
      print("${uniqueId}_cookies_$name");
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
    prefs.setStringList('${uniqueId}_cookies_$name', [cookies]);
    print("save cookies");
    print("${uniqueId}_cookies_$name");
    print(cookies);

    print("clear in save");
    _globalCookieManager.clearCookies();
    print("cookies limpias");
    cookies = await _getCookies() ?? '';
    print(cookies);
  }

  Future<void> loadCookies() async {
    // await _globalCookieManager.clearCookies();
    // print("clear cookie in load");
    final prefs = await SharedPreferences.getInstance();
    final cookiesStringList = prefs.getStringList('${uniqueId}_cookies_$name');
    print("load cookie");
    print("${uniqueId}_cookies_$name");
    print(cookiesStringList);
    getCook();
    // List<String> cookiesStringListSinComillas = cookiesStringList!
    //     .map((cookie) => cookie.replaceAll('"', ''))
    //     .toList();
    //
    // if (cookiesStringList != null) {
    //   print("coookk");
    //   final cookie = cookiesStringListSinComillas
    //       .map((cookieString) => Cookie.fromSetCookieValue(cookieString))
    //       .toList();
    //
    //   print("cookie = ${cookie}");
    //   String cookies = cookie.join('; ');
    //
    //   print("cookiesss" + cookies);
    //   cookies.replaceAll('"', '');
    //   print(cookies);
    //
    //   await _globalCookieManager.setCookies(cookie, origin: url);
    //
    //
    //   controller.evaluateJavascript('document.cookie="${cookies.toString()}"');
    //   print("new pasge");
    // }
    if (cookiesStringList != null) {
      print("coookk");
      List<String> cookiesStringListSinComillas = cookiesStringList
          .map((cookie) => cookie.replaceAll('"', ''))
          .toList();
      print(cookiesStringListSinComillas);

      final cookies = cookiesStringListSinComillas
          .map((cookieString) => Cookie.fromSetCookieValue(cookieString))
          .where((cookie) => cookie != null) // Filter out null cookies
          .toList();
      print("cookie = ${cookies}");
      String cookiesHeader = cookies.join('; ');

      print("cookiesss" + cookiesHeader);
      cookiesHeader = cookiesHeader.replaceAll('"', '');
      print(cookiesHeader);
      // await _globalCookieManager.setCookies(cookies, origin: url);

      controller.evaluateJavascript('document.cookie="${cookiesStringList}"');
      print("new pasge");
      _getCookies();
    }
  }

  Future<String?> _getCookies() async {
    print("get cookies");
    String cookies = await controller.evaluateJavascript('document.cookie');
    List<String> cookieList = cookies.split(';').map((e) => e.trim()).toList();

    print(cookies);
    return cookies;
    // final cookies = await _globalCookieManager.getCookies(url) ?? [];
    // return cookies.isEmpty
    //     ? null
    //     : cookies.map((cookie) => cookie.toString()).join(';');
  }

  Future<String?> getCook() async {
    print("get cookies");
    String cookies = await controller.evaluateJavascript('document.cookie');
    List<Cookie> listaCookies = procesarCookies(cookies);
    // Imprimir la información de las cookies
    for (Cookie cookie in listaCookies) {
      print('Nombre: ${cookie.name}');
      print('Valor: ${cookie.value}');
      print('Dominio: ${cookie.domain}');
      print('Ruta: ${cookie.path}');
      print('---------------');
    }
  }

  List<Cookie> procesarCookies(String cookiesString) {
    List<Cookie> listaCookies = [];

    // Dividir la cadena de cookies en cookies individuales
    List<String> cookiesList = cookiesString.split(';');

    // Procesar cada cookie individualmente
    for (String cookieString in cookiesList) {
      // Dividir la cookie en nombre y valor
      List<String> cookieParts = cookieString.trim().split('=');

      // Verificar si hay al menos dos partes (nombre y valor)
      if (cookieParts.length >= 2) {
        String nombre = cookieParts[0];
        String valor = cookieParts[1];

        // Crear una instancia de Cookie y agregarla a la lista
        Cookie cookie = Cookie(nombre, valor);
        listaCookies.add(cookie);
      }
    }

    return listaCookies;
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
                    widget.page.clearCookies();

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
                    widget.page.clearCookies();

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
        onWebViewCreated: (WebViewController webViewController) {
          // webViewController = widget.page.controller;
          widget.page.controller = webViewController;
          widget.page.loadCookies();
        },
        onPageFinished: (String url) {
          widget.page.saveCookies();
        },
      ),
    );
  }
}
