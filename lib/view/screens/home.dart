import 'package:begabung_app/view/providers/alumno_provider.dart';
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

  // Aquí defines tus pantallas
  final List<Widget> _pages = [
    const SesionesScreen(),
    const EvaluacionesScreen(),
    const NotificacionesScreen(),
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
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Valoraciones',
          ),
        ],
        //currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        //onTap: _onItemTapped,
      ),
    );
  }
}
