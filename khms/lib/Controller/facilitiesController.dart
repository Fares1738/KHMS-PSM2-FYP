// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacilitiesController {
  final _firestore = FirebaseFirestore.instance;

  // Submit a new facility booking
  Future<Facilities> submitFacilityBooking(Facilities facilityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') as String;

      facilityData.studentId = storedStudentId;
      final docRef =
          await _firestore.collection('facilities').add(facilityData.toMap());

      facilityData.facilityApplicationId =
          docRef.id; // Update with the generated ID
      await docRef.update({'facilityApplicationId': docRef.id});

      return facilityData; // Return the updated facilityData for further use
    } catch (error) {
      rethrow; // Rethrow the error for handling at the UI level
    }
  }
}
