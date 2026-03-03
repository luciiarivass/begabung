import 'package:begabung_app/view/providers/auxiliar_provider.dart';
import 'package:begabung_app/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/entities.dart';

class HomeAuxiliarScreen extends StatefulWidget {
  static const String route = 'home_auxiliar_screen';
  @override
  _HomeAuxiliarScreenState createState() => _HomeAuxiliarScreenState();
}

class _HomeAuxiliarScreenState extends State<HomeAuxiliarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SesionesAuxiliarScreen(),
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
        title: const Text('Begabung'),
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
    );
  }
}
