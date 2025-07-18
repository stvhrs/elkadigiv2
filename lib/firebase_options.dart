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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNZoi27IP1bMb65MVgKlQqEtYHfvkHD3Q',
    appId: '1:969146186573:web:ec3ac0b16b54635313d504',
    messagingSenderId: '969146186573',
    projectId: 'elkapede',
    authDomain: 'elkapede.firebaseapp.com',
    databaseURL:
        'https://elkapede-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'elkapede.firebasestorage.app',
    measurementId: 'G-ZNH7QPG9Q8',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQs_mAvTnAuaXS95HfOK6-I0Qcxltj7U4',
    appId: '1:969146186573:ios:3b1bbcd494b6bc1413d504',
    messagingSenderId: '969146186573',
    projectId: 'elkapede',
    databaseURL:
        'https://elkapede-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'elkapede.firebasestorage.app',
    androidClientId:
        '969146186573-d8fo7u7i4o742cqb8gv7mvpospckti4v.apps.googleusercontent.com',
    iosClientId:
        '969146186573-386unr6et178qp3f9p92kbbl95t2q99q.apps.googleusercontent.com',
    iosBundleId: 'com.gph.elkadigiv2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQYU2GMVItTxtWggbVGPz3p3pbB-gfuqw',
    appId: '1:969146186573:android:d472e706888561c213d504',
    messagingSenderId: '969146186573',
    projectId: 'elkapede',
    databaseURL:
        'https://elkapede-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'elkapede.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQs_mAvTnAuaXS95HfOK6-I0Qcxltj7U4',
    appId: '1:969146186573:ios:3b1bbcd494b6bc1413d504',
    messagingSenderId: '969146186573',
    projectId: 'elkapede',
    databaseURL:
        'https://elkapede-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'elkapede.firebasestorage.app',
    androidClientId:
        '969146186573-d8fo7u7i4o742cqb8gv7mvpospckti4v.apps.googleusercontent.com',
    iosClientId:
        '969146186573-386unr6et178qp3f9p92kbbl95t2q99q.apps.googleusercontent.com',
    iosBundleId: 'com.gph.elkadigiv2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNZoi27IP1bMb65MVgKlQqEtYHfvkHD3Q',
    appId: '1:969146186573:web:fe9a1f8322661e3713d504',
    messagingSenderId: '969146186573',
    projectId: 'elkapede',
    authDomain: 'elkapede.firebaseapp.com',
    databaseURL:
        'https://elkapede-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'elkapede.firebasestorage.app',
    measurementId: 'G-J4ZKWL6JKK',
  );
}
