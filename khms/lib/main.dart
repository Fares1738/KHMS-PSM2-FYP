import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khms/View/welcomePage.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: '1:819742488371:android:4b223d23a81a07f1e3f046',
      apiKey: 'AIzaSyAR2OhAC-bPoxVdnkLlPEK4FbUoq3AmHj0',
      projectId: 'khms-d556a',
      messagingSenderId: '819742488371',
      databaseURL: 'https://khms-d556a-default-rtdb.firebaseio.com',
      storageBucket: 'khms-d556a.appspot.com',
      authDomain: 'khms-d556a.firebaseapp.com',
    ),
  );
  runApp(const WelcomePage());
}


