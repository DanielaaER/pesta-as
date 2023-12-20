import 'package:flutter/material.dart';
import 'package:organization/pages/app.dart';
import 'package:organization/pages/explorer.dart';
import 'package:organization/pages/vista.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> pestanasAbiertas = [];
  List<String> urlAbiertas = [];
  TextEditingController controller = TextEditingController();
  String nombre = "click para ver mas";

  String url = "sin pestaña abierta";

  @override
  void initState() {
    super.initState();
    cargarPestanasGuardadas();
  }

  void cargarPestanasGuardadas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pestanasAbiertas = prefs.getStringList('pestanas') ?? [];
      nombre = pestanasAbiertas.first;
      urlAbiertas = prefs.getStringList('urls') ?? [];
      url = urlAbiertas.first;
    });
  }

  // Guardar pestanas en SharedPreferences
  void guardarPestanas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('pestanas', pestanasAbiertas);
    prefs.setStringList('urls', pestanasAbiertas);
  }

  @override
  Widget build(BuildContext context) {
    if (pestanasAbiertas.isEmpty) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppScreen(),
                ),
              );
            },
            child: Text(
              '+',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: ExplorerScreen(),
      );
    }
  }
}
