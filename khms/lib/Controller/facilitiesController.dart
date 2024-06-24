// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:khms/Model/Student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khms/Model/Facilities.dart';
import 'package:khms/View/Student/studentMainPage.dart';

class FacilitiesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Facilities> submitFacilityBooking(
      BuildContext context, Facilities facilityData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('userId') ?? '';

      facilityData.studentId = storedStudentId;

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

  Stream<List<String>> streamBookedTimeSlots(
      DateTime? selectedDate, String? facilityType) {
    if (selectedDate == null || facilityType == null) {
      return Stream.value([]);
    }

    final dayStart = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0);
    final dayEnd = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 23, 59);

    return _firestore
        .collection('Facilities')
        .doc(facilityType)
        .collection('Applications')
        .where('facilityApplicationDate',
            isGreaterThanOrEqualTo: dayStart, isLessThanOrEqualTo: dayEnd)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => doc.data()['facilitySlot'] as String)
          .toList();
    });
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

  Future<void> addFacility(String facilityType) async {
    final facilitiesCollection =
        FirebaseFirestore.instance.collection('Facilities');

    final Map<String, dynamic> facilityData = {
      'isEnabled': true,
    };

    // Create an empty Map<String, dynamic> for the subcollection document
    final Map<String, dynamic> emptySubcollectionDoc = {};

    // Generate a unique document ID for the subcollection document
    final documentId = facilitiesCollection
        .doc(facilityType)
        .collection('Applications')
        .doc()
        .id; // Get the unique ID before the transaction

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Add the new facility as a document
      transaction.set(facilitiesCollection.doc(facilityType), facilityData);

      // Create the document within the subcollection
      transaction.set(
          facilitiesCollection
              .doc(facilityType)
              .collection('Applications')
              .doc(documentId), // Use the generated ID
          emptySubcollectionDoc);

      // Delete the document within the subcollection using the generated ID
      transaction.delete(facilitiesCollection
          .doc(facilityType)
          .collection('Applications')
          .doc(documentId)); // Use the generated ID
    });
  }

  Stream<List<Facilities>> fetchFacilityApplicationsStream() {
    return _firestore
        .collectionGroup('Applications')
        .snapshots()
        .asyncMap((applicationsSnapshot) async {
      final List<Facilities> facilities = [];

      // Fetch all student data in one go
      QuerySnapshot studentsSnapshot =
          await _firestore.collection('Students').get();

      // Create a map for efficient student lookups
      final studentMap = Map.fromEntries(
        studentsSnapshot.docs.map(
          (doc) => MapEntry(doc.id, Student.fromFirestore(doc)),
        ),
      );

      for (var doc in applicationsSnapshot.docs) {
        final facilityData = doc.data();
        final studentId = facilityData['studentId'] as String;
        final facilityType = doc.reference.parent.parent!
            .id; // Get facility type from the parent document's ID

        // Add the Facility object to the list directly
        facilities.add(Facilities(
          facilityApplicationId: doc.id,
          facilityApplicationDate:
              (facilityData['facilityApplicationDate'] as Timestamp).toDate(),
          facilitySlot: facilityData['facilitySlot'] as String,
          facilityType: facilityType,
          studentId: studentId,
          studentRoomNo: studentMap[studentId]?.studentRoomNo ?? '',
          facilityApplicationStatus: facilityData['facilityStatus'] as String,
          student: studentMap[studentId],
        ));
      }

      return facilities; // Return the list of Facilities
    });
  }

  Future<void> updateFacilityApplicationStatus(
      String applicationId, String status, String facilityType) async {
    await _firestore
        .collection('Facilities')
        .doc(facilityType)
        .collection('Applications')
        .doc(applicationId)
        .update({'facilityStatus': status});
  }

  List<Facilities> sortFacilityApplicationsByDate(
      List<Facilities> facilities, String sortByDate) {
    if (sortByDate == 'Newest') {
      facilities.sort((a, b) =>
          b.facilityApplicationDate.compareTo(a.facilityApplicationDate));
    } else {
      facilities.sort((a, b) =>
          a.facilityApplicationDate.compareTo(b.facilityApplicationDate));
    }
    return facilities;
  }

  List<Facilities> sortFacilityApplicationsByStatus(
      List<Facilities> facilities, String sortByStatus) {
    if (sortByStatus == 'All') {
      return facilities;
    } else {
      facilities.sort((a, b) {
        final statusOrder = {
          'Pending': 0,
          'Approved': 1,
          'Rejected': 2,
        };
        return statusOrder[a.facilityApplicationStatus]!
            .compareTo(statusOrder[b.facilityApplicationStatus]!);
      });
      return facilities
          .where(
              (facility) => facility.facilityApplicationStatus == sortByStatus)
          .toList();
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.warning_amber_rounded;
      case 'Approved':
        return Icons.check_circle_outline;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.question_mark;
    }
  }
}
