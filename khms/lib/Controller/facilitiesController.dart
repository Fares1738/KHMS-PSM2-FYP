// ignore_for_file: file_names, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacilitiesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Facilities> submitFacilityBooking(
      BuildContext context, Facilities facilityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') ?? '';

      print(storedStudentId);

      facilityData.studentId = storedStudentId;
      final docRef =
          await _firestore.collection('Facilities').add(facilityData.toMap());

      facilityData.facilityApplicationId = docRef.id;
      await docRef.update({'facilityApplicationId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facility Booking Submitted!")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentMainPage()),
      );

      //return facilityData;
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting booking: ${error.message}')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $error")));
    }
    return facilityData;
  }

  Future<List<String>> fetchBookedTimeSlots(
      DateTime? selectedDate, String? facilityType) async {
    final bookedSlots = <String>[];

    final dayStart =
        DateTime(selectedDate!.year, selectedDate.month, selectedDate.day);
    final dayEnd = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59);

    final querySnapshot = await _firestore
        .collection('Facilities')
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
