// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khms/View/Common/welcomePage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final user = snapshot.data!;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Students')
                  .doc(user.uid)
                  .get(),
              builder: (context, studentSnapshot) {
                if (studentSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (studentSnapshot.hasData && studentSnapshot.data!.exists) {
                  // Extract the student name from the Firestore document
                  final studentData =
                      studentSnapshot.data!.data() as Map<String, dynamic>;
                  final studentName = studentData['studentFirstName'] +
                      ' ' +
                      studentData['studentLastName'];

                  return StudentMainPage(studentName: studentName);
                } else {
                  return const StaffHomePage();
                }
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
