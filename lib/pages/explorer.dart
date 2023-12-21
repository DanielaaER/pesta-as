    import 'package:flutter/material.dart';
    import 'package:organization/pages/home.dart';
import 'package:organization/pages/view.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    import 'app.dart';

    class ExplorerScreen extends StatefulWidget {
      @override
      _ExplorerScreenState createState() => _ExplorerScreenState();
    }

    class _ExplorerScreenState extends State<ExplorerScreen> {
      List<String> pestanasAbiertas = [];
      List<String> urlAbiertas = [];
      TextEditingController controller = TextEditingController();
      String nombre = "regresar";

      @override
      void initState() {
        super.initState();
        cargarPestanasGuardadas();
      }

      // Cargar pestanas guardadas desde SharedPreferences
      void cargarPestanasGuardadas() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          pestanasAbiertas = prefs.getStringList('pestanas') ?? [];
          urlAbiertas = prefs.getStringList('urls') ?? [];
        });
      }

      // Guardar pestanas en SharedPreferences
      void guardarPestanas() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList('pestanas', pestanasAbiertas);
        prefs.setStringList('urls', urlAbiertas);
      }

      // Eliminar pestana
      void eliminarPestana(String pestana, String url) {
        setState(() {
          pestanasAbiertas.remove(pestana);
          urlAbiertas.remove(url);
          guardarPestanas();
        });
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.deepPurple,
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
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ));
                      },
                      child: Text(
                        "$nombre",
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
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return ListTile(
                        title: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ViewPage(
                                  page: Pestana(
                                    name: pestanasAbiertas[index],
                                    url: urlAbiertas[index],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(pestanasAbiertas[index]),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => eliminarPestana(
                            pestanasAbiertas[index],
                            urlAbiertas[index],
                          ),
                        ),
                      );
                    },
                    childCount: pestanasAbiertas.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
