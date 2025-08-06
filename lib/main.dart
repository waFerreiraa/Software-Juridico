import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'package:jurisolutions/navegacao/home.dart';
import 'package:jurisolutions/navegacao/inicio.dart';
import 'package:jurisolutions/splash/splash.dart';

String? fcmToken;

/// Handler para notificações recebidas em segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Mensagem em segundo plano: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Define o handler para notificações em segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Solicita permissão (Android 13+ e iOS)
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission();
  print('🔐 Permissão de notificação: ${settings.authorizationStatus}');

  // Obtém o token do dispositivo
  fcmToken = await FirebaseMessaging.instance.getToken();
  print('📱 FCM Token: $fcmToken');

  // Notificação recebida com app em primeiro plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📬 Foreground: ${message.notification?.title}');
  });

  // App foi aberto via toque na notificação
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 App aberto pela notificação: ${message.notification?.title}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/home': (context) => const RoteadorTela(),
      },
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage(); // Usuário logado
        } else {
          return const InicioTela(); // Usuário não logado
        }
      },
    );
  }
}
