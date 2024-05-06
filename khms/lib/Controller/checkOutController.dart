// ignore_for_file: use_build_context_synchronously, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckOutApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutController {
  Future<bool> submitCheckOutApplication(BuildContext context,
      DateTime? checkOutDate, TimeOfDay? checkOutTime) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') as String;

      if (checkOutDate != null && checkOutTime != null) {
        final checkOutApplication = CheckOutApplication(
          checkOutApplicationDate: DateTime.now(),
          checkOutApplicationId: '',
          checkOutDate: checkOutDate,
          checkOutStatus: 'Pending',
          checkOutTime: checkOutTime.format(context),
          studentId: storedStudentId,
        );

        // Add to Firestore; gets auto-generated ID
        DocumentReference docRef = await firestore
            .collection('CheckOutApplications')
            .add(checkOutApplication.toMap());

        // Update the checkOutApplicationId
        await docRef.update({'checkOutApplicationId': docRef.id});

        return true; // Indicate success
      } else {
        return false; // Incomplete data
      }
    } catch (e) {
      print('Error submitting check-out application: $e');
      return false; // Indicate error
    }
  }
}
