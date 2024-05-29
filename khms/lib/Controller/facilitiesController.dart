import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class FacilitiesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Facilities> submitFacilityBooking(
      BuildContext context, Facilities facilityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') ?? '';

      print(storedStudentId);

      facilityData.studentId = storedStudentId;

      // Check if the facility is enabled
      final isEnabled = await isFacilityEnabled(facilityData.facilityType);
      if (!isEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "This facility is currently disabled and cannot be booked.")),
        );
        return facilityData;
      }

      final docRef = await _firestore
          .collection('Facilities')
          .doc(facilityData.facilityType)
          .collection('Applications')
          .add(facilityData.toMap());

      facilityData.facilityApplicationId = docRef.id;
      await docRef.update({'facilityApplicationId': docRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facility Booking Submitted!")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentMainPage()),
      );
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

  Future<Map<String, bool>> fetchFacilityAvailability() async {
    final Map<String, bool> facilityAvailability = {};
    final querySnapshot = await _firestore.collection('Facilities').get();

    for (final doc in querySnapshot.docs) {
      facilityAvailability[doc.id] = doc.data()['isEnabled'] as bool? ?? false;
    }

    return facilityAvailability;
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
        .doc(facilityType)
        .collection('Applications')
        .where('facilityApplicationDate',
            isGreaterThanOrEqualTo: dayStart, isLessThanOrEqualTo: dayEnd)
        .get();

    for (final doc in querySnapshot.docs) {
      bookedSlots.add(doc.data()['facilitySlot'] as String);
    }

    return bookedSlots;
  }

  Future<void> toggleFacilityAvailability(
      String facilityType, bool isEnabled) async {
    await _firestore
        .collection('Facilities')
        .doc(facilityType)
        .update({'isEnabled': isEnabled});
  }

  Future<bool> isFacilityEnabled(String facilityType) async {
    final doc =
        await _firestore.collection('Facilities').doc(facilityType).get();
    return doc.data()?['isEnabled'] ?? false;
  }

  Future<List<Facilities>> fetchFacilityApplications() async {
    final List<Facilities> facilityApplications = [];

    final facilitiesSnapshot = await _firestore.collection('Facilities').get();

    for (final facilityDoc in facilitiesSnapshot.docs) {
      final applicationsSnapshot = await _firestore
          .collection('Facilities')
          .doc(facilityDoc.id)
          .collection('Applications')
          .get();

      for (final applicationDoc in applicationsSnapshot.docs) {
        facilityApplications.add(Facilities.fromMap(applicationDoc.data()));
      }
    }

    return facilityApplications;
  }

  Future<void> updateFacilityApplicationStatus(
      String applicationId, String status, String facilityType) async {
    await _firestore
        .collection('Facilities')
        .doc(facilityType)
        .collection('Applications')
        .doc(applicationId)
        .update({'status': status});
  }
}
