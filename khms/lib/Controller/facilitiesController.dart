// ignore_for_file: file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/View/Student/studentHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacilitiesController {
  final _firestore = FirebaseFirestore.instance;

  // Submit a new facility booking
  Future<Facilities> submitFacilityBooking(
      BuildContext context, Facilities facilityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') as String;

      facilityData.studentId = storedStudentId;
      final docRef =
          await _firestore.collection('facilities').add(facilityData.toMap());

      facilityData.facilityApplicationId =
          docRef.id; // Update with the generated ID
      await docRef.update({'facilityApplicationId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facility Booking Submitted!")));

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const StudentHomePage())); //

      return facilityData; // Return the updated facilityData for further use
    } catch (error) {
      rethrow; // Rethrow the error for handling at the UI level
    }
  }

  Future<List<String>> fetchBookedTimeSlots(
      DateTime? selectedDate, String? facilityType) async {
    final bookedSlots = <String>[];

    // Start and end of selected day for querying
    final dayStart =
        DateTime(selectedDate!.year, selectedDate.month, selectedDate.day);
    final dayEnd = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59);

    final querySnapshot = await _firestore
        .collection('facilities')
        .where('facilityApplicationDate',
            isGreaterThanOrEqualTo: dayStart, isLessThanOrEqualTo: dayEnd)
        .where('facilityType', isEqualTo: facilityType)
        .get();

    for (final doc in querySnapshot.docs) {
      bookedSlots.add(doc.data()['facilitySlot'] as String);
    }

    return bookedSlots;
  }
}
