import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBurJtNu7gIPmevfxJy2L03Vcu6dKyY4BY",
      authDomain: "kixar-5d7d5.firebaseapp.com",
      projectId: "kixar-5d7d5",
      storageBucket: "kixar-5d7d5.firebasestorage.app",
      messagingSenderId: "433622438408",
      appId: "1:433622438408:web:6952afdefcd9f8942237bd",
      measurementId: "G-N8XNEEXHJ3"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      initialRoute: '/',
    );
  }
}
