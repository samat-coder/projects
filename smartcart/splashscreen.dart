import 'dart:async';// Your home screen
import 'package:bookapp/navigation.dart';
import 'package:bookapp/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // User is already logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => mynavigation()),
          );
        } else {
          // User is not logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Image.asset('assets/images/ecomlogo.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
