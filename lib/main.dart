import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'phone_auth_screen.dart';
import 'admin_home.dart';
import 'user_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

ThemeData buildAppTheme() {
  const primaryColor = Color(0xFFA29BFE);
  const surfaceColor = Colors.white;
  const backgroundColor = Color(0xFFF8F9FA);
  const accentDark = Color(0xFF6C5CE7);

  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: const Color(0xFFDFE6E9),
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    background: backgroundColor,
    onBackground: Colors.black,
    surface: surfaceColor,
    onSurface: const Color(0xFF2D3436),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),

    cardTheme: const CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    fontFamily: 'Montserrat',
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthWrapper(),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  Future<String> _createOrGetUser(User user) async {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await docRef.get();

    // If user NOT in database → create with default role = user
    if (!doc.exists) {
      await docRef.set({
        'phone': user.phoneNumber ?? '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return 'user';
    }

    // If exists → return stored role
    final data = doc.data();
    return data?['role'] ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return PhoneAuthScreen();
        }

        final user = snapshot.data!;

        return FutureBuilder<String>(
          future: _createOrGetUser(user),
          builder: (context, roleSnapshot) {

            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data ?? 'user';

            if (role == 'admin') {
              return AdminHome();
            } else {
              return UserHome();
            }
          },
        );
      },
    );
  }
}

