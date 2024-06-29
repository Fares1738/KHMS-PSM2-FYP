// ignore_for_file: no_leading_underscores_for_local_identifiers, file_names, use_build_context_synchronously, avoid_print, unused_catch_clause

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:khms/Model/Staff.dart';
import 'package:khms/Model/Student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khms/View/Common/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance; // Firebase authentication instance
  Student? student;
  Staff? staff;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Getters for the text controllers
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  bool get isAdmin {
    return staff != null && staff!.userType == UserType.Manager;
  }

  Future<void> registerUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final _firebaseMessaging = FirebaseMessaging.instance;
      final fcmToken = await _firebaseMessaging.getToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('fcmToken', fcmToken!);

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
          false,
          fcmToken,
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

  Future<void> changePassword(
      String email, String oldPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      print('Error changing password: $e');
      // Handle error (e.g., show a snackbar or alert dialog)
      throw e; // Rethrow the error if you want to handle it further up the call chain
    }
  }

  // Method to send a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      // Handle error (e.g., show a snackbar or alert dialog)
      throw e; // Rethrow the error if you want to handle it further up the call chain
    }
  }



  Future<void> signOutUser(BuildContext context) async {
    try {
      await _auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error signing out: $e');
      // Handle error (e.g., show a snackbar or alert dialog)
    }
  }

  Future<void> addStaff(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    UserType role,
  ) async {
    try {
      // Create user in Firebase Authentication (use a temporary password)
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporaryPassword123', // Or generate a random password
      );

      // Get the user's UID
      String uid = userCredential.user!.uid;

      // Create a Staff object and store in Firestore
      final newStaff = Staff(
        staffFirstName: firstName,
        staffLastName: lastName,
        staffEmail: email,
        staffPhoneNumber: phoneNumber,
        userType: role,
        staffId: uid, // Use the UID as the staffId
      );

      // Update the student's photo URL in Firestore and in the local Student object
      await FirebaseFirestore.instance
          .collection('Staff') // Create or use an existing 'Staff' collection
          .doc(uid) // Use UID as document ID
          .set(newStaff.toMap());

      // (Optional) Send an email to the new staff member with instructions to reset their password
    } catch (e) {
      // Handle errors (e.g., email already in use)
    }
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userType = prefs.getString('userType');

    if (userId != null && userType != null) {
      // Fetch data from Firestore
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection(userType == 'Students' ? 'Students' : 'Staff')
                .doc(userId)
                .get();

        if (userType == 'Students') {
          student = Student.fromFirestore(snapshot);
        } else {
          staff = Staff.fromFirestore(snapshot);
        }
        notifyListeners();
      } catch (e) {
        print('Error fetching user data: $e');
        // Handle the error (e.g., show a SnackBar)
      }
    }
  }

  Future<void> updateUserData(File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? userType = prefs.getString('userType');

    if (userId != null && imageFile != null) {
      try {
        Reference ref =
            FirebaseStorage.instance.ref().child('profiles/$userId.jpg');
        await ref.putFile(imageFile);

        // Get the download URL of the uploaded image
        String downloadURL = await ref.getDownloadURL();
        print("DownloadURL: $downloadURL");
        // Update the user's photo URL in the correct Firestore collection based on userType
        await FirebaseFirestore.instance
            .collection(userType == 'Students' ? 'Students' : 'Staff')
            .doc(userId)
            .update({
          userType == 'Students' ? 'studentPhoto' : 'staffPhoto': downloadURL,
        });

        // Update the local student or staff object
        if (userType == 'Students') {
          // Updated user type check
          student!.studentPhoto = downloadURL;
        } else {
          staff!.staffPhoto = downloadURL;
        }

        notifyListeners();
      } catch (e) {
        print('Error updating user data: $e');
        // Handle the error (e.g., show a SnackBar)
      }
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    final _firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        // Update email in Firestore collection
        if (user.email != null && userType == 'Students') {
          await _firestore
              .collection('Students')
              .doc(user.uid)
              .update({'studentEmail': newEmail});
        } else {
          await _firestore
              .collection('Staff')
              .doc(user.uid)
              .update({'staffEmail': newEmail});
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating email: $e');
    }
  }

  Future<void> updateUserPhoneNumber(String newPhoneNumber) async {
    final _firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update email in Firestore collection
        if (userType == 'Students') {
          await _firestore
              .collection('Students')
              .doc(user.uid)
              .update({'studentPhoneNumber': newPhoneNumber});
        } else {
          await _firestore
              .collection('Staff')
              .doc(user.uid)
              .update({'staffPhoneNumber': newPhoneNumber});
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error updating phone number: $e');
    }
  }

  // Method to fetch all students
  Future<List<Student>> fetchAllStudents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Students').get();
      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      throw e; // Rethrow the error if you want to handle it further up the call chain
    }
  }

  // Method to fetch all staff
  Future<List<Staff>> fetchAllStaff() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Staff').get();
      return snapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching staff: $e');
      throw e; // Rethrow the error if you want to handle it further up the call chain
    }
  }
}
