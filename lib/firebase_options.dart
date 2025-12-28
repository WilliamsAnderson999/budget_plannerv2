import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-QgIA3Ogjo4fyHt6IWP05smcLuJBB6_8',
    appId: '1:109202637322:web:702e653ccf749bdfa415f3',
    messagingSenderId: '109202637322',
    projectId: 'budgetmanager00-eca60',
    authDomain: 'budgetmanager00-eca60.firebaseapp.com',
    storageBucket: 'budgetmanager00-eca60.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzcfmlJOvYIa9InP81Qc9t-OaVX_bxLJk',
    appId: '1:109202637322:android:3973aa49c40b4176a415f3',
    messagingSenderId: '109202637322',
    projectId: 'budgetmanager00-eca60',
    storageBucket: 'budgetmanager00-eca60.firebasestorage.app',
  );
}
