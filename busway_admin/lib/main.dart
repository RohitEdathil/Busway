import 'package:busway_admin/home/home_screen.dart';
import 'package:busway_admin/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BuswayAdminApp());
}

class BuswayAdminApp extends StatelessWidget {
  const BuswayAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: auth.currentUser == null ? const LoginScreen() : const HomeScreen(),
      theme: ThemeData.light().copyWith(
          primaryColor: Colors.deepPurpleAccent,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
          )),
    );
  }
}
