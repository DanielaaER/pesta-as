import 'dart:io';

import 'package:flutter/material.dart';
import 'package:organization/pages/app.dart';
import 'package:organization/pages/explorer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:webview_flutter/webview_flutter.dart';

class Page {
  final String name;
  final String url;
  final List<String> cookies;

  Page({required this.name, required this.url, required this.cookies});
}

class ViewPage extends StatefulWidget {
  final Page page;
  String nombre = "click para ver mas";
  String url = "no url";
  late WebViewController controller;

  // ViewPage(String link, String text, WebViewController _controller) {
  //   this.nombre = text;
  //   this.url = link;
  //   this.controller = _controller;
  //   print("nombre view ${this.nombre}");
  //   print("url view ${this.nombre}");
  // }
  ViewPage({required this.page});

  @override
  ViewPageState createState() =>
      ViewPageState(this.url, this.nombre, this.controller);
}

class ViewPageState extends State<ViewPage> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  late WebViewController _controller;

  ViewPageState(String link, String text, WebViewController _controller) {
    this._controller = _controller;
    print("nombre view ${widget.page.name}");
    print("url view ${widget.page.url}");
    print("cookie ${widget.page.cookies}");
  }

  TextEditingController controller = TextEditingController();

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
                        fixedSize:
                            Size(MediaQuery.of(context).size.width * .65, 1)),
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
                    )),
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
                      )),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppScreen(),
                        ));
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
          _controller = webViewController;
          _loadCookies();
        },
      ),
    );
  }

  Future<void> _loadCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCookies = prefs.getStringList(widget.page.name);

    if (savedCookies != null) {
      for (String cookie in savedCookies) {
        _controller.evaluateJavascript('document.cookie = "$cookie";');
      }
    }
  }

  Future<void> _saveCookies() async {
    String cookies = await _controller.evaluateJavascript('document.cookie');
    List<String> cookieList = cookies.split(';').map((e) => e.trim()).toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(widget.page.name, cookieList);
  }
}
