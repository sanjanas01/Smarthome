import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'home.dart';
import 'create.dart';
import 'devices.dart';
import 'settings.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context) => LoginPage(),
        '/create':(context) => const CreateAccountPage(),
        '/home':(context) => const HomePage(),
        '/devices':(context) => const DevicesPage(),
        '/settings':(context) => const SettingsPage(),
      },
    );
  }
}
