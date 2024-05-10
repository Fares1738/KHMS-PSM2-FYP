// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_element, file_names, use_build_context_synchronously, avoid_print, unused_catch_clause, unused_local_variable

import 'package:flutter/material.dart';
import 'package:khms/Model/Student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khms/View/Common/loginPage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentController {
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance; // Firebase authentication instance

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Getters for the text controllers
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  Future<void> registerUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (formKey.currentState!.validate()) {
        final _firestore = FirebaseFirestore.instance;
        Student newStudent = Student(DateTime.now(), _emailController.text, '',
            '', '', '', '', '', '', '', '', '',
            userType: 'Student', studentId: userCredential.user!.uid);

        await _firestore
            .collection('Students')
            .doc(userCredential.user!.uid)
            .set(newStudent.toMap());

        // ... (Success Handling) ...
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the login page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors (improved)
      String errorMessage =
          'Registration failed. Please try again.'; // Default message

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Generic error handling
      print('Registration Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registration failed. Please try again.')));
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Fetch student data
      var studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userCredential.user!.uid)
          .get();

      if (studentDoc.exists) {
        // Set the global variable
        String globalStudentId =
            studentDoc.data()!['studentId']; // Adapt if field name differs

        String globalStudentRoomNo =
            studentDoc.data()!['studentRoomNo']; // Adapt if field name differs

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('studentID', globalStudentId);

        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setString('studentRoomNo', globalStudentRoomNo);

        // final prefs3 = await SharedPreferences.getInstance();
        // String? storedStudentId = prefs3.getString('studentID');

        // final prefs4 = await SharedPreferences.getInstance();
        // String? studentRoomNo = prefs4.getString('studentRoomNo');

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StudentHomePage()));

        // Successful login - Navigate to home page (modify as needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StaffHomePage()));
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors
      String errorMessage = 'Authentication failed. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
