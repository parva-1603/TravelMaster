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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKvZmx_k_YT1kdN7wrwwT57aGNJ8cEcqY',
    appId: '1:871934658697:web:dummydummydummy', // Update this via flutterfire configure if needed
    messagingSenderId: '871934658697',
    projectId: 'travelguru1',
    authDomain: 'travelguru1.firebaseapp.com',
    storageBucket: 'travelguru1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKvZmx_k_YT1kdN7wrwwT57aGNJ8cEcqY',
    appId: '1:871934658697:android:e98bc472821e43090a9e58',
    messagingSenderId: '871934658697',
    projectId: 'travelguru1',
    storageBucket: 'travelguru1.firebasestorage.app',
  );
}
