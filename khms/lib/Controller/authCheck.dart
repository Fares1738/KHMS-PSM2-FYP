// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:khms/View/Common/welcomePage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              if (snapshot.hasError) {
                // Handle errors here (e.g., show an error message)
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
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
