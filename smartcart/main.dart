
import 'package:bookapp/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug print for existing Firebase apps
  print('Firebase apps count before init: ${Firebase.apps.length}');

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBu1B7wswfZw5arkCO8sQklsYUmTQicCq8",
          authDomain: "ecomproject-6d914.firebaseapp.com",
          projectId: "ecomproject-6d914",
          storageBucket: "ecomproject-6d914.appspot.com", // Use .appspot.com
          messagingSenderId: "1098877784292",
          appId: "1:1098877784292:web:d1c5edccd7ab94a1489cf1",
          measurementId: "G-7JDSF6N1MF",
        ),
      );
      print('Firebase initialized');
    } else {
      print('Firebase already initialized');
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase app already initialized, skipping initialization.');
    } else {
      rethrow;
    }
  }

  Stripe.publishableKey =
      'pk_test_51RTfX9IoKvtNfT9dqNknukz1H4vDkO8P3VfBAXKA61GXuglMRBVNpCdocx4kkEZ0Oz56V2qafBaYmVO0R8CZq3H000SGcNNX1y';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Splashscreen(),
        );
      },
    );
  }
}
