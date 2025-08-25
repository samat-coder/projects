import 'dart:async';
import 'package:admin_ecom/login.dart';
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
      const Duration(seconds: 5),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>const LoginScreen()
          ),
        );
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
                width: 500,
                height: 400,
                    child: Image.asset('assets/images/ecomlogo.png'),
                  ),
           ),
            
          ],
      ),
    ),
    );
  }
}