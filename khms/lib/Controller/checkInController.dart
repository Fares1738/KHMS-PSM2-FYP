// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:khms/Controller/globals.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/View/Student/studentCheckInPage_Second.dart';

class CheckInController {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passportController = TextEditingController();
  final _checkInDateController = TextEditingController();
  final _phoneNoController = TextEditingController();
  final _nationalityController = TextEditingController();

  // Getters
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get passportController => _passportController;
  TextEditingController get checkInDateController => _checkInDateController;
  TextEditingController get phoneNoController => _phoneNoController;
  TextEditingController get nationalityController => _nationalityController;

  Future<void> submitCheckInApplication(
      BuildContext context,
      String firstName,
      String lastName,
      String passportNo,
      String checkInDate,
      String phoneNo,
      String nationality) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      // Create CheckInApplication with placeholder
      CheckInApplication newApplication = CheckInApplication(
        checkInApplicationDate: DateTime.now(),
        checkInApplicationId: '', // Placeholder
        checkInDate: _checkInDateController.text,
        studentId: globalStudentId, // Link to the student
        checkInStatus: 'Pending', // Initial status?
      );

      // Add to Firestore; gets auto-generated ID
      DocumentReference docRef = await _firestore
          .collection('CheckInApplications')
          .add(newApplication.toMap());

      // Update the checkInApplicationId
      await docRef.update({'checkInApplicationId': docRef.id});

      await _firestore.collection('Students').doc(globalStudentId).update({
        'firstName': firstName,
        'lastName': lastName,
        'passportNo': passportNo,
        'phoneNo': phoneNo,
        'nationality': nationality,
      });

      print('First Name: $firstName');
      print('globalStudentId: $globalStudentId');

      // ... Success Handling (Navigation, etc.) ...

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CheckInPageSecond()));
    } on FirebaseException {
      // ... Handle Firebase-related errors
    } catch (e) {
      // ... Generic errors
    }
  }
}
