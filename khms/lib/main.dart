import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:khms/Controller/authCheck.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/api/firebase_api.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: '1:819742488371:android:4b223d23a81a07f1e3f046',
      apiKey: 'AIzaSyAR2OhAC-bPoxVdnkLlPEK4FbUoq3AmHj0',
      projectId: 'khms-d556a',
      messagingSenderId: '819742488371',
      databaseURL: 'https://khms-d556a-default-rtdb.firebaseio.com',
      storageBucket: 'gs://khms-d556a.appspot.com',
    ),
  );

  FirebaseApi firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserController(),
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: const AuthCheck(),
      ),
    ),
  );
}
