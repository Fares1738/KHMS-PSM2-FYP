import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:khms/Controller/authCheck.dart';
import 'package:khms/Controller/userController.dart';
import 'package:khms/api/firebase_api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: FirebaseOptions(
      appId: '1:819742488371:android:4b223d23a81a07f1e3f046',
      apiKey: dotenv.env['FIREBASE_API_KEY'] as String,
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
