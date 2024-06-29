import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:khms/View/Common/welcomePage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();

  // Static method to sign in with email and password
  static Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    _AuthCheckState state = context.findAncestorStateOfType<_AuthCheckState>()!;
    await state._signInWithEmailAndPassword(email, password);
  }
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'User not found');
      }

      String uid = user.uid;

      // Fetch student and staff documents concurrently
      List<DocumentSnapshot> docs = await Future.wait([
        _firestore.collection('Students').doc(uid).get(),
        _firestore.collection('Staff').doc(uid).get(),
      ]);

      DocumentSnapshot studentDoc = docs[0];
      DocumentSnapshot staffDoc = docs[1];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final _firebaseMessaging = FirebaseMessaging.instance;
      final fcmToken = await _firebaseMessaging.getToken();

      if (fcmToken == null) {
        throw FirebaseAuthException(
            code: 'fcm-token-error', message: 'Failed to get FCM token');
      }

      if (studentDoc.exists) {
        // Student login
        await prefs.setString('userId', uid);
        await prefs.setString('userType', 'Students');
        await prefs.setString(
            'studentRoomNo', studentDoc.get('studentRoomNo') ?? '');
        await prefs.setString('fcmToken', fcmToken);
        String studentUserType = prefs.getString('userType') ?? '';
        print('User type from Student: $studentUserType');

        await _firestore
            .collection('Students')
            .doc(uid)
            .update({'fcmToken': fcmToken});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student login successful!')),
          );
        }
      } else if (staffDoc.exists) {
        // Staff login
        await prefs.setString('userId', uid);

        // Get userType directly from Firestore
        String userType = staffDoc.get('userType');
        await prefs.setString('userType', userType);
        print('User type from Staff: $userType');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff login successful!')),
          );
        }
      } else {
        // User not found in either collection
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found in any collection');
      }

      // Trigger a rebuild of the widget tree
      if (mounted) setState(() {});
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message ?? 'Login failed. Please try again.')),
        );
      }
    } catch (e) {
      // Handle other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait([
              _firestore.collection('Students').doc(user.uid).get(),
              _firestore.collection('Staff').doc(user.uid).get(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                DocumentSnapshot studentDoc = snapshot.data![0];
                DocumentSnapshot staffDoc = snapshot.data![1];

                if (studentDoc.exists) {
                  return StudentMainPage();
                } else if (staffDoc.exists) {
                  return const StaffHomePage();
                }
              }
              return const WelcomePage();
            },
          );
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}
