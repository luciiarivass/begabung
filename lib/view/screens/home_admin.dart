import 'package:begabung_app/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/entities.dart';

class HomeAdminScreen extends StatefulWidget {
  static const String route = 'home_admin_screen';
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SesionesAdminScreen(),
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Begabung'),
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
      /*bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Sesiones',s
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Evaluaciones',
          ),*/
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),*/
    );
  }
}
