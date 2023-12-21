import 'package:flutter/material.dart';
import 'package:organization/pages/view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';


class AppScreen extends StatefulWidget {
  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  List<String> pestanasAbiertas = [];
  List<WebViewController> webAbierto = [];
  List<String> id = [];

  List<String> urlAbiertas = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarPestanasGuardadas();
  }

  void cargarPestanasGuardadas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pestanasAbiertas = prefs.getStringList('pestanas') ?? [];
      urlAbiertas = prefs.getStringList('urls') ?? [];
      id = prefs.getStringList('idU') ?? [];
    });
  }

  // Guardar pestanas en SharedPreferences
  void guardarPestanas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('pestanas', pestanasAbiertas);
    prefs.setStringList('urls', urlAbiertas);
    prefs.setStringList('idU', id);
  }

  // Añadir nueva pestana
  void agregarPestana(String nombre, IconData icono, String url) {
    setState(() {
      pestanasAbiertas.add(nombre);
      urlAbiertas.add(url);
      controller.clear();
      id.add(pestanasAbiertas.length.toString());
      guardarPestanas();
    });
  }

  Future<void> mostrarCuadroDialogo(
      BuildContext context, IconData icono, String url) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese el nombre de la pestaña'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Nombre de la pestaña',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                var nombre = controller.text;
                agregarPestana(controller.text, icono, url);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ViewPage(
                    page: Pestana(
                      name: nombre,
                      url: url,
                      uniqueId: pestanasAbiertas.length.toString(),
                    ),
                  ),
                ));
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        title: Container(
          child: Text("Apps"),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: aplicaciones.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              mostrarCuadroDialogo(
                  context, aplicaciones[index].icono, aplicaciones[index].url);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(aplicaciones[index].icono),
                  SizedBox(height: 8),
                  Text(aplicaciones[index].nombre),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Aplicacion {
  final IconData icono;
  final String nombre;
  final String url;

  Aplicacion({required this.icono, required this.nombre, required this.url});
}

List<Aplicacion> aplicaciones = [
  Aplicacion(icono: Icons.facebook, nombre: 'Facebook', url: "https://m.facebook.com/"),
  Aplicacion(icono: Icons.chat, nombre: 'WhatsApp', url: "https://web.whatsapp.com"),
  Aplicacion(
      icono: Icons.camera_alt, nombre: 'Instagram', url: "https://www.instagram.com/"),

  Aplicacion(
      icono: Icons.mail, nombre: 'Gmail', url: "https://www.gmail.com/"),
  Aplicacion(icono: Icons.add, nombre: "Twitter", url: "https://twitter.com/"),

  Aplicacion(icono: Icons.add, nombre: "Outlook", url: "https://outlook.office.com/mail/")
];
