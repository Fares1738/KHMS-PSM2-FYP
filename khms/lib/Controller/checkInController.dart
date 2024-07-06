// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, empty_catches, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Room.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Student/stripePaymentPage.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:khms/api/firebase_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CheckInController {
  Future<void> submitCheckInApplication(
      BuildContext context,
      String firstName,
      String lastName,
      String passportNo,
      DateTime checkInDate,
      String phoneNo,
      String nationality,
      String matricNumber,
      String icNumber,
      DateTime dateofBirth,
      String roomType,
      int price,
      String? checkInApplicationId,
      String? rejectionReason,
      File? frontMatricPic,
      File? backMatricPic,
      File? passportMyKadPic,
      File? studentPhoto,
      bool isPaid) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      final prefs2 = await SharedPreferences.getInstance();
      String? storedStudentId = prefs2.getString('userId') as String;

      CheckInApplication newApplication = CheckInApplication(
          checkInApplicationDate: DateTime.now(),
          checkInApplicationId: checkInApplicationId ?? '',
          checkInDate: checkInDate,
          studentId: storedStudentId,
          checkInStatus: 'Pending',
          checkInApprovalDate: DateTime
              .now(), //Placeholder value, will be updated after approval
          roomType: roomType,
          price: price,
          isPaid: false);

      if (checkInApplicationId == null ||
          checkInApplicationId.isEmpty ||
          checkInApplicationId == '') {
        DocumentReference docRef = await _firestore
            .collection('CheckInApplications')
            .add(newApplication.toMap());

        await docRef.update({'checkInApplicationId': docRef.id});
        checkInApplicationId =
            docRef.id; // Update the local variable with the new ID
      } else {
        await _firestore
            .collection('CheckInApplications')
            .doc(checkInApplicationId)
            .update({
          'checkInApplicationDate':
              Timestamp.fromDate(newApplication.checkInApplicationDate),
          'checkInDate': Timestamp.fromDate(newApplication.checkInDate),
          'studentId': newApplication.studentId,
          'checkInStatus': newApplication.checkInStatus,
          'roomType': newApplication.roomType,
          'price': newApplication.price,
          'rejectionReason': '',
        });
      }

      await _firestore.collection('Students').doc(storedStudentId).update({
        'studentFirstName': firstName,
        'studentLastName': lastName,
        'studentmyKadPassportNumber': passportNo,
        'studentPhoneNumber': phoneNo,
        'studentNationality': nationality,
        'studentDoB': Timestamp.fromDate(dateofBirth),
        'studentIcNumber': icNumber,
        'studentMatricNo': matricNumber,
      });

      if (frontMatricPic != null) {
        final imageURL1 = await _uploadImageToFirebase(frontMatricPic);
        await _firestore.collection('Students').doc(storedStudentId).update({
          'frontMatricCardImage': imageURL1,
        });
      }

      if (backMatricPic != null) {
        final imageURL2 = await _uploadImageToFirebase(backMatricPic);
        await _firestore.collection('Students').doc(storedStudentId).update({
          'backMatricCardImage': imageURL2,
        });
      }

      if (passportMyKadPic != null) {
        final imageURL3 = await _uploadImageToFirebase(passportMyKadPic);
        await _firestore.collection('Students').doc(storedStudentId).update({
          'passportMyKadImage': imageURL3,
        });
      }

      if (studentPhoto != null) {
        final imageURL4 = await _uploadImageToFirebase(studentPhoto);
        await _firestore.collection('Students').doc(storedStudentId).update({
          'studentPhoto': imageURL4,
        });
      }

      //String studentName = '$firstName $lastName';

      if (isPaid == false) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StripePaymentPage(
                      studentId: storedStudentId,
                      priceWithDeposit: price + 580,
                      checkInApplicationId: checkInApplicationId ?? '',
                    )));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => StudentMainPage()));
      }
    } on FirebaseException {
    } catch (e) {
      print('Error submitting check-in application: $e');
    }
  }

  Stream<List<Room>> getAvailableRoomsStream(
      String roomType, String blockName, int floorNumber) {
    // floorNumber is optional
    Query<Map<String, dynamic>> query = _firestore
        .collection('Blocks')
        .doc('Block $blockName')
        .collection('Rooms')
        .where('roomAvailability', isEqualTo: true)
        .where('roomType', isEqualTo: roomType)
        .where('floorNumber', isEqualTo: floorNumber);

    return query.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  Stream<List<CheckInApplication>> fetchCheckInApplicationsStream() {
    final _firestore = FirebaseFirestore.instance;

    return _firestore
        .collection('CheckInApplications')
        .snapshots()
        .asyncMap((applicationsSnapshot) async {
      final applications = applicationsSnapshot.docs
          .map((doc) => CheckInApplication.fromFirestore(doc))
          .toList();

      final studentIds = applications.map((app) => app.studentId).toSet();
      final studentsFutureMap = {
        for (var studentId in studentIds)
          studentId: _firestore.collection('Students').doc(studentId).get()
      };
      final studentsSnapshot = await Future.wait(studentsFutureMap.values);

      final studentMap = Map.fromEntries(
        studentsSnapshot
            .map((doc) => MapEntry(doc.id, Student.fromFirestore(doc))),
      );

      for (var application in applications) {
        application.student = studentMap[application.studentId];
      }

      return applications;
    });
  }

  Future<int> getAssignedTenantsCount(String roomNo) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('CheckInApplications')
          .where('roomNo', isEqualTo: roomNo)
          .where('checkInStatus', isEqualTo: 'Approved')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting assigned tenants: $e');
      return 0;
    }
  }

  Future updateCheckInApplication(CheckInApplication application,
      String newStatus, String? roomNo, String? rejectionReason) async {
    try {
      final firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();
      Map<String, dynamic> updateData = {
        'checkInStatus': newStatus,
        if (newStatus == 'Approved') 'checkInApprovalDate': Timestamp.now(),
        if (newStatus == 'Approved') 'isPaid': true,
      };
      if (roomNo != null) {
        updateData['roomNo'] = roomNo;
      }
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updateData['rejectionReason'] = rejectionReason;
      }
      batch.update(
        firestore
            .collection('CheckInApplications')
            .doc(application.checkInApplicationId),
        updateData,
      );

      // Update the Student document
      Map<String, dynamic> studentUpdateData = {'studentRoomNo': roomNo};
      if (newStatus == 'Approved') {
        studentUpdateData['lastRentPaidDate'] = Timestamp.now();
      }
      batch.update(
        firestore.collection('Students').doc(application.studentId),
        studentUpdateData,
      );

      if (newStatus == 'Approved' &&
          roomNo != null &&
          application.roomType == 'Single') {
        String blockName = roomNo.substring(0, 1);
        batch.update(
          firestore
              .collection('Blocks')
              .doc('Block $blockName')
              .collection('Rooms')
              .doc(roomNo),
          {'roomAvailability': false},
        );
      }
      // Check if room type is double or triple
      if (newStatus == 'Approved' &&
          roomNo != null &&
          application.roomType != 'Single') {
        final assignedCount = await getAssignedTenantsCount(roomNo);
        final capacity = application.roomType == 'Double' ? 2 : 3;
        if (assignedCount == capacity - 1) {
          // Update roomAvailability to false
          batch.update(
            firestore
                .collection('Blocks')
                .doc('Block ${roomNo[0]}')
                .collection('Rooms')
                .doc(roomNo),
            {'roomAvailability': false},
          );
        }
      }
      await batch.commit();
      FirebaseApi.sendNotification(
        'CheckInApplications',
        application.checkInApplicationId,
        'Check-In Application Status Update',
        'Your check-in application status has been $newStatus. Open the app to view details.',
      );
    } on FirebaseException catch (e) {
      print('Firebase Error updating check-in application: $e');
    } catch (e) {
      print('Error updating check-in application: $e');
    }
  }

  Future<CheckInApplication?> getCheckInApplication(String studentId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('CheckInApplications')
          .where('studentId', isEqualTo: studentId)
          .get();
      if (query.docs.isNotEmpty) {
        return CheckInApplication.fromFirestore(
            query.docs.first as DocumentSnapshot<Object?>);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> resubmitApplication(CheckInApplication application) async {
    try {
      await _firestore
          .collection('CheckInApplications')
          .doc(application.checkInApplicationId)
          .update({'checkInStatus': 'Pending'});
    } catch (e) {
      print('Error resubmitting application: $e');
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    // Create a unique file name (you might integrate timestamps, user IDs, etc.)
    String fileName = DateTime.now().toString();

    // Define storage reference (adjust the path as needed)
    final storageRef =
        FirebaseStorage.instance.ref().child('checkInImages/$fileName');

    // Upload task
    final UploadTask uploadTask = storageRef.putFile(image);

    // Handle progress if desired

    // Wait for upload completion
    final TaskSnapshot downloadSnapshot =
        await uploadTask.whenComplete(() => null);

    // Retrieve the download URL
    final String downloadUrl = await downloadSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  final _firestore = FirebaseFirestore.instance;

  Future<void> updateCheckInApplicationWithPayment(
      String checkInApplicationId, String studentId, int rentDaysLeft) async {
    try {
      // Update the CheckInApplication document in Firestore
      await _firestore
          .collection('CheckInApplications')
          .doc(checkInApplicationId)
          .update({
        'isPaid': true,
      });

      // Update the Student document in Firestore
      await _firestore.collection('Students').doc(studentId).update({
        'lastRentPaidDate': DateTime.now().add(Duration(days: rentDaysLeft)),
      });
    } catch (e) {
      throw Exception(
          'Error updating check-in application or student document: $e');
    }
  }
}
