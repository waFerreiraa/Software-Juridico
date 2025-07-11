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
    apiKey: 'AIzaSyB4IrWei4Xb9gLf6n7puUaYejue33Mwrog',
    appId: '1:221563948679:web:74c7a4ba03dbd17d9f7222',
    messagingSenderId: '221563948679',
    projectId: 'jurisolutions',
    authDomain: 'jurisolutions.firebaseapp.com',
    storageBucket: 'jurisolutions.firebasestorage.app',
    measurementId: 'G-L3WVVX6JF8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2PmWc-_7g5ZxTjFeT26jQmSWd79XUYh4',
    appId: '1:221563948679:android:c77ac9757e4bcde89f7222',
    messagingSenderId: '221563948679',
    projectId: 'jurisolutions',
    storageBucket: 'jurisolutions.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsEWhyctc8vyI80VzUYAijGgzVTPwk9Qw',
    appId: '1:221563948679:ios:606b2f198f7f0ceb9f7222',
    messagingSenderId: '221563948679',
    projectId: 'jurisolutions',
    storageBucket: 'jurisolutions.firebasestorage.app',
    androidClientId: '221563948679-i3tiotovkjhiin1crk7vt33n6p6d9cng.apps.googleusercontent.com',
    iosBundleId: 'com.example.jurisolutions',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsEWhyctc8vyI80VzUYAijGgzVTPwk9Qw',
    appId: '1:221563948679:ios:606b2f198f7f0ceb9f7222',
    messagingSenderId: '221563948679',
    projectId: 'jurisolutions',
    storageBucket: 'jurisolutions.firebasestorage.app',
    androidClientId: '221563948679-i3tiotovkjhiin1crk7vt33n6p6d9cng.apps.googleusercontent.com',
    iosBundleId: 'com.example.jurisolutions',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBsaiAu7LXxFBelwKAo41wUmLXeVtcUQ4Y',
    appId: '1:123599106616:web:d35862b013fa8a0334accd',
    messagingSenderId: '123599106616',
    projectId: 'jurisolutions-3ed1f',
    authDomain: 'jurisolutions-3ed1f.firebaseapp.com',
    storageBucket: 'jurisolutions-3ed1f.firebasestorage.app',
    measurementId: 'G-DFNF0RQRDZ',
  );

}