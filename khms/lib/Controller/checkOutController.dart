// ignore_for_file: use_build_context_synchronously, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckOutApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:khms/api/firebase_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khms/Model/Student.dart';

class CheckOutController {
  Future<void> submitCheckOutApplication(
      BuildContext context, DateTime? checkOutDate) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final String? storedStudentId = prefs.getString('userId');

      if (storedStudentId == null) {
        print('Student ID not found in SharedPreferences');
      }

      if (checkOutDate != null) {
        final checkOutApplication = CheckOutApplication(
          checkOutApplicationDate: DateTime.now(),
          checkOutApplicationId: '',
          checkOutDate: checkOutDate,
          checkOutStatus: 'Pending',
          studentId: storedStudentId!,
        );

        // Add to Firestore; gets auto-generated ID
        DocumentReference docRef = await firestore
            .collection('CheckOutApplications')
            .add(checkOutApplication.toMap());

        // Update the checkOutApplicationId
        await docRef.update({'checkOutApplicationId': docRef.id});

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Check-Out Application Submitted!")));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentMainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a date!")));
      }
    } catch (e) {
      print('Error submitting check-out application: $e');
    }
  }

  Stream<List<CheckOutApplication>> fetchCheckOutApplicationsStream() {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('CheckOutApplications')
        .snapshots() // Listen for changes in CheckOutApplications collection
        .asyncMap((applicationsSnapshot) async {
      // Use asyncMap to handle async operations within the stream

      final applications = applicationsSnapshot.docs
          .map((doc) => CheckOutApplication.fromFirestore(doc))
          .toList();

      // Fetch student data in parallel using a map
      final studentIds = applications
          .map((app) => app.studentId)
          .toSet(); // Unique student IDs
      final studentsFutureMap = {
        for (var studentId in studentIds)
          studentId: firestore.collection('Students').doc(studentId).get()
      };
      final studentsSnapshot = await Future.wait(studentsFutureMap.values);

      final studentMap = Map.fromEntries(
        studentsSnapshot
            .map((doc) => MapEntry(doc.id, Student.fromFirestore(doc))),
      );

      // Attach student data to applications
      for (var application in applications) {
        application.student = studentMap[application.studentId];
      }

      return applications;
    });
  }

  Future<void> updateCheckOutnApplicationStatus(CheckOutApplication application,
      String newStatus, DateTime? selectedTime) async {
    // Make selectedTime optional
    try {
      final firestore = FirebaseFirestore.instance;

      // Create a map to update the document
      Map<String, dynamic> updateData = {'checkOutStatus': newStatus};

      // Add checkOutTime only if it's provided (when starting the checkout)
      if (selectedTime != null) {
        updateData['checkOutTime'] = selectedTime;
      }

      WriteBatch batch = firestore.batch(); // Create a batch for atomic updates

      batch.update(
        firestore
            .collection('CheckOutApplications')
            .doc(application.checkOutApplicationId),
        updateData,
      );

      FirebaseApi.sendNotification(
        'CheckOutApplications',
        application.checkOutApplicationId,
        'Check-Out Status is $newStatus',
        'Your check-out time will be at ${selectedTime!.hour}:${selectedTime.minute}. Check the app for more details.',
      );

      // Clear studentRoomNo if checkout is completed
      if (newStatus == 'Completed') {
        batch.update(
          firestore.collection('Students').doc(application.studentId),
          {'studentRoomNo': ''}, // Set studentRoomNo to empty
        );
      }

      await batch.commit(); // Commit both updates as a single transaction
    } catch (e) {
      // Handle errors appropriately (e.g., display a snackbar)
      print('Error updating check-out application status: $e');
    }
  }

  Future<void> updateRoomAvailability(String roomNo, bool isAvailable) async {
    // Extract block name from roomNo (e.g., 'A' from 'A101')
    String blockName = roomNo.substring(0, 1);

    try {
      await FirebaseFirestore.instance
          .collection('Blocks')
          .doc('Block $blockName')
          .collection('Rooms')
          .doc(roomNo)
          .update({'roomAvailability': isAvailable});
    } catch (e) {
      // Handle errors
      print('Error updating room availability: $e');
    }
  }

  Future<void> deleteUserDocuments(String studentId) async {
    try {

      List<String> relatedCollections = [
        'CheckInApplications',
        'Complaints',
      ];

      // Delete documents from related collections
      for (String collection in relatedCollections) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('studentId', isEqualTo: studentId)
            .get();

        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // Handle special case for Facilities collection with Applications subcollection
      QuerySnapshot facilitiesSnapshot =
          await FirebaseFirestore.instance.collection('Facilities').get();

      for (QueryDocumentSnapshot facilityDoc in facilitiesSnapshot.docs) {
        QuerySnapshot applicationsSnapshot = await facilityDoc.reference
            .collection('Applications')
            .where('studentId', isEqualTo: studentId)
            .get();

        for (QueryDocumentSnapshot applicationDoc
            in applicationsSnapshot.docs) {
          await applicationDoc.reference.delete();
        }
      }

      // Finally, delete the student document itself
    } catch (e) {
      // Handle errors
      print('Error deleting user documents: $e');
    }
  }
}
