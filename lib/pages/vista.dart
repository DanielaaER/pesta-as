// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart';
//
// import 'app.dart';
// import 'explorer.dart';
//
// class Pestana {
//   final String name;
//   final String url;
//   final String uniqueId;
//   late WebViewController controller;
//
//   Pestana({required this.name, required this.url})
//       : uniqueId = UniqueKey().toString();
// }
//
// class ViewPage extends StatefulWidget {
//   final Pestana page;
//
//   ViewPage({required this.page});
//
//   @override
//   ViewPageState createState() => ViewPageState();
// }
//
// class ViewPageState extends State<ViewPage> {
//   late WebViewController _controller;
//   final cookieManager = WebviewCookieManager();
//   late WebviewCookieManager _cookieManager; // Use a dedicated cookie manager for each WebView
//   @override
//   void initState() {
//     super.initState();
//     _cookieManager = WebviewCookieManager();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         automaticallyImplyLeading: false,
//         title: Container(
//           child: Row(
//             children: [
//               Container(
//                 alignment: AlignmentDirectional.centerStart,
//                 width: MediaQuery
//                     .of(context)
//                     .size
//                     .width * .72,
//                 child: TextButton(
//                   style: TextButton.styleFrom(
//                     primary: Colors.transparent,
//                     padding: EdgeInsets.zero,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     visualDensity: VisualDensity.compact,
//                     fixedSize: Size(MediaQuery
//                         .of(context)
//                         .size
//                         .width * .65, 1),
//                   ),
//                   onPressed: () {
//                     _saveCookies();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ExplorerScreen(),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "${widget.page.name}",
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 width: MediaQuery
//                     .of(context)
//                     .size
//                     .width * .2,
//                 alignment: AlignmentDirectional.centerEnd,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     primary: Colors.transparent,
//                     onPrimary: Colors.black,
//                     fixedSize: Size(
//                       MediaQuery
//                           .of(context)
//                           .size
//                           .width * .00001,
//                       MediaQuery
//                           .of(context)
//                           .size
//                           .height * .001,
//                     ),
//                   ),
//                   onPressed: () {
//                     _saveCookies();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AppScreen(),
//                       ),
//                     );
//                   },
//                   child: Text("+"),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//       body: WebView(
//         initialUrl: widget.page.url,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           widget.page.controller = webViewController;
//           _loadCookies();
//         },
//         onPageFinished: (String url) {
//           _saveCookies();
//         },
//
//       ),
//     );
//   }
//
//   Future<void> _loadCookies() async {
//     List<Cookie> cookies = await _cookieManager.getCookies(widget.page.name) ??
//         [];
//
//     if (cookies.isNotEmpty) {
//       await _cookieManager.setCookies(cookies);
//     }
//   }
//
//   Future<void> _saveCookies() async {
//     Cookie cookie = Cookie(
//       widget.page.name,
//       widget.page.uniqueId,
//     )
//       ..domain = widget.page.url
//       ..expires = DateTime.now().add(Duration(days: 10))
//       ..httpOnly = false;
//
//     await _cookieManager.setCookies([cookie]);
//     clearCookies();
//   }
//
//   // You can call this method when you want to clear cookies, for example, when logging out.
//   Future<void> clearCookies() async {
//     await _cookieManager.clearCookies();
//   }
// }