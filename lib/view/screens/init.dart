import 'package:begabung_app/view/providers/admin_provider.dart';
import 'package:begabung_app/view/providers/auxiliar_provider.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final needsUpdate = await _checkVersion();
      if (!needsUpdate) {
        await _checkLogin(); // solo si no hay update bloqueante
      }
    });
  }

  Future<bool> _checkVersion() async {
    try {
      final newVersion = NewVersionPlus(
          iOSId: 'com.carlospherraz.begabungapp',
          androidId: 'com.carlospherraz.begabungapp');
      final status = await newVersion.getVersionStatus().timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          );

      if (status != null && status.canUpdate) {
        print("HOLA");
        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());
        if (!mounted) return true;
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogTitle: 'Nueva versión disponible',
          dialogText:
              'Existe una versión más reciente de la aplicación. Por favor, actualiza antes de continuar.',
          launchModeVersion: LaunchModeVersion.external,
          allowDismissal: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error al verificar versión: $e');
      return false;
    }
  }

  Future<void> checkForUpdateAndClearStorage() async {
    final info = await PackageInfo.fromPlatform();
    const storage = FlutterSecureStorage();
    final currentVersion = info.version; // e.g. "1.0.1"
    final savedVersion = await storage.read(key: 'app_version');
    if (savedVersion == null || savedVersion != currentVersion) {
      // Si no hay versión guardada o es distinta, borra y actualiza
      await storage.deleteAll();
      await storage.write(key: 'app_version', value: currentVersion);
    }
  }

  Future<Login?> isLogged() async {
    const storage = FlutterSecureStorage();
    String? idlogin = await storage.read(key: 'id');
    String? apikey = await storage.read(key: 'apikey');
    String? idfamilia = await storage.read(key: 'idfamilia');
    if (idlogin == null || apikey == null) {
      return null;
    }
    Login? login = Login();
    login = await login.loginId(idlogin, apikey);
    if (login == null) {
      return null;
    }
    if (login.idfamiliaalumno != 0 && idfamilia == null) {
      await storage.write(
          key: 'idfamilia', value: login.idfamiliaalumno.toString());
    }
    return login;
  }

  Future<void> _checkLogin() async {
    try {
      await checkForUpdateAndClearStorage().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint(
              'Timeout en checkForUpdateAndClearStorage, continuando...');
        },
      );

      final login = await isLogged().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Timeout en isLogged, redirigiendo a login');
          return null;
        },
      );

      if (!mounted) return;

      debugPrint('==== LOGIN DEBUG ====');
      if (login != null) {
        debugPrint('login.idlogin: ${login.idlogin}');
        debugPrint('login.idprofesional: ${login.idprofesional}');
        debugPrint('login.idfamiliaalumno: ${login.idfamiliaalumno}');
        debugPrint('login.auxiliar: ${login.auxiliar}');
        debugPrint('login.admin: ${login.admin}');
        debugPrint('login.mantenimiento: ${login.mantenimiento}');

        if (login.mantenimiento) {
          debugPrint('>>> Redirigiendo a /mantenimiento');
          context.go('/mantenimiento');
        } else if (login.idprofesional != 0) {
          debugPrint('>>> Redirigiendo a /home_profesional');
          context.read<ProfesionalProvider>().getInfo(login.idprofesional);
          context.go('/home_profesional');
        } else if (login.idfamiliaalumno != 0) {
          debugPrint('>>> Redirigiendo a /hijos');
          context.go('/hijos');
        } else if (login.auxiliar == true) {
          debugPrint('>>> Redirigiendo a /home_auxiliar');
          context.read<AuxiliarProvider>().getInfo();
          context.go('/home_auxiliar');
        } else if (login.admin == true) {
          debugPrint('>>> Redirigiendo a /home_admin');
          context.read<AdminProvider>().getInfo();
          context.go('/home_admin');
        } else {
          debugPrint('>>> No encaja en ninguna rama, redirigiendo a /login');
          context.go('/login');
        }
      } else {
        debugPrint('>>> login es null, redirigiendo a /login');
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error en _checkLogin: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
