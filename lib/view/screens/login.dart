import 'package:begabung_app/domain/entities/api.dart';
import 'package:begabung_app/domain/entities/entities.dart';
import 'package:begabung_app/view/providers/admin_provider.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'lib/assets/images/fondo 1.jpg'), // Ruta de la imagen de fondo
                fit: BoxFit.cover,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          const SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 240,
                ),
                SizedBox(
                  height: 74,
                  child: Text(
                    '¡Bienvenido!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1C4474),
                      fontSize: 40,
                      fontFamily: 'Open Sans Hebrew',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  ),
                ),
                _LoginForm()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => __LoginFormState();
}

class __LoginFormState extends State<_LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String user = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 90, vertical: 20),
            child: TextFormField(
              onChanged: (value) => user = value,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                labelStyle: TextStyle(
                  color: Color(0xFF1C4474),
                  fontSize: 20,
                  fontFamily: 'Open Sans Hebrew',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 90, vertical: 20),
            child: TextFormField(
              onChanged: (value) => password = value,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(
                  color: Color(0xFF1C4474),
                  fontSize: 20,
                  fontFamily: 'Open Sans Hebrew',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                Login login = Login();
                try {
                  login = await login.login(user, password);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Error login: $e"),
                  ));
                }
                if (login.mantenimiento) {
                  GoRouter.of(context).go('/mantenimiento');
                } else if (login.admin || login.auxiliar) {
                  // ← PRIMERO ADMIN/AUX
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'apikey', value: login.apikey);
                  await storage.write(
                      key: 'id', value: login.idlogin.toString());
                  await storage.write(
                      key: 'is_auxiliar', value: login.auxiliar ? '1' : '0');

                  context.read<ProfesionalProvider>().clearInfo();
                  context.read<AdminProvider>().getInfo();

                  GoRouter.of(context).go('/home_admin');
                } else if (login.idprofesional != 0) {
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'apikey', value: login.apikey);
                  await storage.write(
                      key: 'id', value: login.idlogin.toString());

                  context.read<ProfesionalProvider>().clearInfo();
                  context
                      .read<ProfesionalProvider>()
                      .getInfo(login.idprofesional);
                  GoRouter.of(context).go('/home_profesional');
                } else if (login.idfamiliaalumno != 0) {
                  List alumnos = await Familiaalumno.getAlumnos(
                      login.idfamiliaalumno, login.apikey!);
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'apikey', value: login.apikey);
                  await storage.write(
                      key: 'id', value: login.idlogin.toString());
                  await storage.write(
                      key: 'idfamilia',
                      value: login.idfamiliaalumno.toString());
                  await _initFirebaseMessaging(context, login, alumnos[0])
                      .catchError((e) {
                    print('Error al inicializar Firebase Messaging: $e');
                    /*if (alumnos.length == 1) {
                    context
                        .read<AlumnoProvider>()
                        .getInfo(alumnos[0].idalumno ?? 0);
                    GoRouter.of(context).go('/home');
                  } else {
                    alumnoProvider.hermanos = true;*/
                    GoRouter.of(context).go('/hijos', extra: alumnos);
                  });
                }
              },
              child: const Text('Entrar',
                  style: TextStyle(
                    color: Color(0xFF1C4474),
                    fontSize: 20,
                    fontFamily: 'Open Sans Hebrew',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  )),
            ),
          ),
        ]));
  }

  Future<void> _initFirebaseMessaging(
      BuildContext ctx, Login login, Alumno alumno) async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    String? token = await FirebaseMessaging.instance.getToken();

    if (token == null) {
      if (ctx.mounted) {
        await showDialog(
          context: ctx,
          builder: (_) => AlertDialog(
            title: const Text('No se obtuvo token FCM (null)'),
            content: const Text(
                'Las notificaciones push no funcionarán en este dispositivo'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(_), child: const Text('OK'))
            ],
          ),
        );
      }
      return;
    }

    FirebaseMessaging.instance.subscribeToTopic("sede_${alumno.idsede}");
    FirebaseMessaging.instance.subscribeToTopic('todos');
    var url = Uri.parse('${Api.base}/api/3/apikeyes/${login.idlogin}');
    await http
        .put(url, headers: {'Token': login.apikey!}, body: {'token': token});
  }
}
