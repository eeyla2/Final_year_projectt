// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAN1MVjy9Q5SjrJYL_4Rga8cEpYVRln8-o',
    appId: '1:962506045459:web:db180f2663b873e37b27e6',
    messagingSenderId: '962506045459',
    projectId: 'legsfree',
    authDomain: 'legsfree.firebaseapp.com',
    storageBucket: 'legsfree.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdP0C1dO39xbGvYXuu9QAbA9h6_tdlWzc',
    appId: '1:962506045459:android:929223a34e42a9ff7b27e6',
    messagingSenderId: '962506045459',
    projectId: 'legsfree',
    storageBucket: 'legsfree.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsi_ZFdwDy8d68DN2L3NqCsHoqODjJR2M',
    appId: '1:962506045459:ios:612e5cc981367f3d7b27e6',
    messagingSenderId: '962506045459',
    projectId: 'legsfree',
    storageBucket: 'legsfree.appspot.com',
    androidClientId: '962506045459-rhrpf0mj9130q9hlthnfs5vhb68su2qb.apps.googleusercontent.com',
    iosClientId: '962506045459-hlnlmncess95ugrpffj72a5piin9fhv1.apps.googleusercontent.com',
    iosBundleId: 'com.legsfree.legsfree',
  );
}
