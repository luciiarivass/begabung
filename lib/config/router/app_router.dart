import 'package:begabung_app/domain/entities/entities.dart';
//import 'package:begabung_app/view/providers/admin_provider.dart';
//import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:begabung_app/view/screens/home_auxiliar.dart';
import 'package:begabung_app/view/screens/screens.dart';
import 'package:begabung_app/view/screens/sesion_grupo.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
//import 'package:provider/provider.dart';

/*Future<Login?> isLogged() async {
  const storage = FlutterSecureStorage();
  String? idlogin = await storage.read(key: 'id');
  String? apikey = await storage.read(key: 'apikey');
  String? idfamilia = await storage.read(key: 'idfamilia');
  if (idlogin == null || apikey == null) {
    return null;
  }
  Login login = Login();
  login = await login.loginId(idlogin, apikey);
  if (login.idfamiliaalumno != 0 && idfamilia == null) {
    await storage.write(
        key: 'idfamilia', value: login.idfamiliaalumno.toString());
  }
  return login;
}*/

// GoRouter configuration
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const InitScreen(),
      /*redirect: (context, state) async {
          Login? login = await isLogged();
          if (login != null) {
            if (login.idprofesional != 0) {
              context.read<ProfesionalProvider>().getInfo(login.idprofesional);
              return '/home_profesional';
            } else if (login.idfamiliaalumno != 0) {
              return '/hijos';
            } else if (login.admin == true) {
              context.read<AdminProvider>().getInfo();
              return '/home_admin';
            }
          } else {
            return '/login';
          }
          return '/login';
        }*/
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: HomeScreen.route,
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      name: MantenimientoScreen.route,
      path: '/mantenimiento',
      builder: (context, state) => const MantenimientoScreen(),
    ),
    GoRoute(
      name: HomeProfesionalScreen.route,
      path: '/home_profesional',
      builder: (context, state) => HomeProfesionalScreen(),
    ),
    GoRoute(
      name: HomeAdminScreen.route,
      path: '/home_admin',
      builder: (context, state) => HomeAdminScreen(),
    ),
    GoRoute(
      name: HomeAuxiliarScreen.route,
      path: '/home_auxiliar',
      builder: (context, state) => HomeAuxiliarScreen(),
    ),
    GoRoute(
  path: '/sesiones-grupo',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    final grupo = extra['grupo'] as Grupo;

    return SesionesGrupoScreen(
      grupo: grupo,
    );
  },
),

   GoRoute(
  name: GrupoScreen.route,
  path: '/grupo',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    final grupo = extra['grupo'] as Grupo;
    final sesion = extra['sesion'] as Sesion;

    return GrupoScreen(
      grupo: grupo,
      idsesion: sesion.idsesion ?? 0,
    );
  },
),
    GoRoute(
        name: EvaluacionScreen.route,
        path: '/evaluacion',
        builder: (context, state) {
          final evaluacion = state.extra as Evaluacion;
          return EvaluacionScreen(evaluacion: evaluacion);
        }),
    GoRoute(
        name: HijosScreen.route,
        path: '/hijos',
        builder: (context, state) {
          // final alumnos = state.extra as List<Alumno>;
          //return HijosScreen(alumnos: alumnos);
          return HijosScreen();
        }),
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => const NotificacionesScreen(),
    ),
  ],
);
