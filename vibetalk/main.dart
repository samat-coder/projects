import 'package:firebasedatabase/firebase_options.dart';
import 'package:firebasedatabase/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Signup', // Optional: App title
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MySplashScreen()
    );
  }
}
