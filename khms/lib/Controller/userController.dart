// ignore_for_file: no_leading_underscores_for_local_identifiers, file_names, use_build_context_synchronously, avoid_print, unused_catch_clause

import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:khms/Model/Student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khms/View/Common/loginPage.dart';
import 'package:khms/View/Common/welcomePage.dart';
import 'package:khms/View/Staff/staffHomePage.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance; // Firebase authentication instance
  Student? student;
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
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (formKey.currentState!.validate()) {
        final _firestore = FirebaseFirestore.instance;
        Student newStudent = Student(
          DateTime.now(),
          _emailController.text,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          userType: 'Student',
          studentId: userCredential.user!.uid,
        );

        await _firestore
            .collection('Students')
            .doc(userCredential.user!.uid)
            .set(newStudent.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to the login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    } catch (e) {
      print('Registration Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }

    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch student data
      var studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userCredential.user!.uid)
          .get();

      if (studentDoc.exists) {
        String globalStudentId = studentDoc.data()!['studentId'];
        String globalStudentRoomNo = studentDoc.data()!['studentRoomNo'] ?? '';

        String firstName = studentDoc.data()!['studentFirstName'];
        String lastName = studentDoc.data()!['studentLastName'];
        String studentName;

        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          studentName = '$firstName $lastName';
        } else {
          studentName = 'Student';
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('studentID', globalStudentId);
        await prefs.setString('studentRoomNo', globalStudentRoomNo);

        print('Student ID: $globalStudentId');
        print('Student Room No: $globalStudentRoomNo');
        print('Student Name: $studentName');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StudentMainPage(
                    studentName: studentName,
                  )),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffHomePage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Authentication failed. Please try again.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        errorMessage = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    notifyListeners();
  }

  Future<void> signOutUser(BuildContext context) async {
    try {
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Future<void> fetchStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString('studentID');

    if (studentId != null) {
      // Try to load data from cache first
      String? cachedStudentData = prefs.getString('cachedStudentData');
      if (cachedStudentData != null) {
        Map<String, dynamic> studentMap = jsonDecode(cachedStudentData);
        student = Student.fromJson(studentMap);
        notifyListeners();
      }

      // Fetch data from Firestore
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('Students')
            .doc(studentId)
            .get();

        student = Student.fromFirestore(snapshot);

        // Cache the fetched data
        await prefs.setString('cachedStudentData', jsonEncode(student!.toJson()));
        notifyListeners();
      } catch (e) {
        print('Error fetching student data: $e');
        // Handle the error (e.g., show a SnackBar)
      }
    }
  }

  Future<void> updateStudentData(File? _imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? studentId = prefs.getString('studentID');
    print('Student ID: $studentId');
    if (studentId != null && _imageFile != null) {
      print('Updating student data...');
      print(studentId);
      print(_imageFile);
      try {
        // Upload the image to Firebase Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('student_profiles/$studentId.jpg');
        await ref.putFile(_imageFile);

        // Get the download URL of the uploaded image
        String downloadURL = await ref.getDownloadURL();
        print("DownloadURL: $downloadURL");
        // Update the student's photo URL in Firestore and in the local Student object
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(studentId)
            .update({'studentPhoto': downloadURL});
      } catch (e) {
        print('Error updating student data: $e');
        // Handle the error (e.g., show a SnackBar)
      }
    }
  }
}
