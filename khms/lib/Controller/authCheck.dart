import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khms/View/Common/welcomePage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? studentName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
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
                if (snapshot.hasError) {
                  Future.delayed(Duration.zero, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${snapshot.error}')),
                    );
                  });
                  return const Center(
                    child: Text('An error occurred. Please try again.'),
                  );
                }
                if (snapshot.hasData) {
                  DocumentSnapshot studentDoc = snapshot.data![0];
                  DocumentSnapshot staffDoc = snapshot.data![1];

                  if (studentDoc.exists) {
                    studentName = studentDoc.get('studentFirstName') + ' ' + studentDoc.get('studentLastName');
                    return StudentMainPage(studentName: studentName!);
                  } else if (staffDoc.exists) {
                    return const StaffHomePage();
                  }
                }
                Future.delayed(Duration.zero, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'User profile not found. Please enter correct credentials or sign up.')),
                  );
                });
                return const WelcomePage();
              },
            );
          } else {
            return const WelcomePage();
          }
        },
      ),
    );
  }
}
