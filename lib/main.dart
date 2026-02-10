import 'package:begabung_app/config/router/app_router.dart';
import 'package:begabung_app/view/providers/admin_provider.dart';
import 'package:begabung_app/view/providers/alumno_provider.dart';
import 'package:begabung_app/view/providers/profesional_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_new_badger/flutter_new_badger.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'config/theme/app_theme.dart';

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handler para mensajes en segundo plano
  print("Notificación en segundo plano: ${message.messageId}");
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  FlutterNewBadger.removeBadge();
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlumnoProvider()),
        ChangeNotifierProvider(create: (_) => ProfesionalProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider())
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'Begabung',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(),
      ),
    );
  }
}
