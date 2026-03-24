import 'package:begabung_app/domain/entities/alumno.dart';
import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:begabung_app/view/providers/recurso_provider.dart';
import 'package:begabung_app/view/screens/competencias_screen.dart';
import 'package:begabung_app/view/screens/recursos_alumno_screen.dart';
import 'package:begabung_app/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';

class HomeScreen extends StatefulWidget {
  static const String route = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SesionesScreen(),
    const EvaluacionesScreen(),
    const _RecursosTab(),   // ← gestiona su propia navegación interna
    const ValoracionScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _modalPassword(BuildContext context) {
    TextEditingController inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Introduce tu nueva contraseña'),
          content: TextField(
            controller: inputController,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () async {
                bool resultado = false;
                String valor = inputController.text;
                if (valor.isNotEmpty) {
                  resultado = await Login().cambioPassword(valor);
                }
                if (resultado) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Contraseña cambiada correctamente. Vuelve a iniciar sesión, por favor'),
                    ),
                  );
                  GoRouter.of(context).go('/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al cambiar la contraseña'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final alumnoProvider = context.watch<AlumnoProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: alumnoProvider.hermanos
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(alumnoProvider.alumno?.nombre ?? ''),
            const SizedBox(height: 5),
            Text(
              alumnoProvider.grupo?.split(' ')[0] ?? '',
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificaciones',
            onPressed: () {
              GoRouter.of(context).push('/notificaciones');
            },
          ),
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            onSelected: (int value) async {
              switch (value) {
                case 1:
                  _modalPassword(context);
                  break;
                case 2:
                  const storage = FlutterSecureStorage();
                  await storage.deleteAll();

                  context.read<RecursoProvider>().clearRecursos();

                  GoRouter.of(context).go('/');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Cambiar contraseña'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Sesiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Evaluaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Valoraciones',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Widget que gestiona la navegación interna del tab Recursos:
/// Competencias → RecursosAlumno, sin salir del Scaffold de HomeScreen.
class _RecursosTab extends StatefulWidget {
  const _RecursosTab();

  @override
  State<_RecursosTab> createState() => _RecursosTabState();
}

class _RecursosTabState extends State<_RecursosTab> {
  int? _idInteligencia;
  String? _nombreInteligencia;

  @override
  Widget build(BuildContext context) {
    if (_idInteligencia != null) {
      final alumno = context.read<AlumnoProvider>().alumno!;
      return RecursosAlumnoScreen(
        alumno: alumno,
        idinteligencia: _idInteligencia,
        nombreInteligencia: _nombreInteligencia,
        onBack: () => setState(() {
          _idInteligencia = null;
          _nombreInteligencia = null;
        }),
      );
    }

    return CompetenciasScreen(
      onSelectInteligencia: (id, nombre) {
        setState(() {
          _idInteligencia = id;
          _nombreInteligencia = nombre;
        });
      },
    );
  }
}
