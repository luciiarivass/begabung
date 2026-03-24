import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:begabung_app/view/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';

class HomeProfesionalScreen extends StatefulWidget {
  static const String route = 'home_profesional_screen';
  @override
  _HomeProfesionalScreenState createState() => _HomeProfesionalScreenState();
}

class _HomeProfesionalScreenState extends State<HomeProfesionalScreen> {
  int _selectedIndex = 0;

  // Aquí defines tus pantallas
  final List<Widget> _pages = [
    const SesionesProfesionalScreen(),
    const EvaluacionesProfesionalScreen(),
    const RecursosProfesionalScreen(),
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
    final profesionalProvider = context.watch<ProfesionalProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(profesionalProvider.profesional?.nombre ?? ''),
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
            icon: Icon(Icons.menu_book),
            label: 'Recursos',
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
