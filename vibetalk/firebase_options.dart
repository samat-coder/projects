// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBAoQSWAhJ-o_gDi1p7vqc1EJbhUIj8RKc',
    appId: '1:751050541066:web:32cdbf45598473a671f7f3',
    messagingSenderId: '751050541066',
    projectId: 'octflutterfbproject-a187e',
    authDomain: 'octflutterfbproject-a187e.firebaseapp.com',
    storageBucket: 'octflutterfbproject-a187e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLuMMOXrqea4tfIDKHTv3Rufmv5ZSr_7E',
    appId: '1:751050541066:android:e9547e5ae984f5a171f7f3',
    messagingSenderId: '751050541066',
    projectId: 'octflutterfbproject-a187e',
    storageBucket: 'octflutterfbproject-a187e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWb8BHe9RqnPuN7zJrVxMG7ebQvgKjN_4',
    appId: '1:751050541066:ios:654268ca76e03aeb71f7f3',
    messagingSenderId: '751050541066',
    projectId: 'octflutterfbproject-a187e',
    storageBucket: 'octflutterfbproject-a187e.firebasestorage.app',
    iosBundleId: 'com.example.firebasedatabase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBWb8BHe9RqnPuN7zJrVxMG7ebQvgKjN_4',
    appId: '1:751050541066:ios:654268ca76e03aeb71f7f3',
    messagingSenderId: '751050541066',
    projectId: 'octflutterfbproject-a187e',
    storageBucket: 'octflutterfbproject-a187e.firebasestorage.app',
    iosBundleId: 'com.example.firebasedatabase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBAoQSWAhJ-o_gDi1p7vqc1EJbhUIj8RKc',
    appId: '1:751050541066:web:857668d1af4cabbd71f7f3',
    messagingSenderId: '751050541066',
    projectId: 'octflutterfbproject-a187e',
    authDomain: 'octflutterfbproject-a187e.firebaseapp.com',
    storageBucket: 'octflutterfbproject-a187e.firebasestorage.app',
  );
}
