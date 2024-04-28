// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_element, file_names, use_build_context_synchronously, avoid_print, unused_catch_clause, unused_local_variable

import 'package:flutter/material.dart';
import 'package:khms/Controller/globals.dart';
import 'package:khms/Model/Student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khms/View/Common/loginPage.dart';
import 'package:khms/View/Student/studentHomePage.dart';

class StudentController {
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance; // Firebase authentication instance

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Getters for the text controllers
  TextEditingController get usernameController => _usernameController;
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
            '', '', '', 0, '', '', '', '', '',
            userName: _usernameController.text,
            userPassword: _passwordController.text,
            userType: 'Student',
            studentId: userCredential.user!.uid);

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
        globalStudentId =
            studentDoc.data()!['studentId']; // Adapt if field name differs


        // Successful login - Navigate to home page (modify as needed)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
      } else {
        // Handle non-existent student data (if applicable)
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
