// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, empty_catches

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Student/studentHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CheckInController {
  Future<void> submitCheckInApplication(
    BuildContext context,
    String firstName,
    String lastName,
    String passportNo,
    String checkInDate,
    String phoneNo,
    String nationality,
    String matricNumber,
    String icNumber,
    String dateofBirth,
    String roomType,
    int duration,
    int price,
    File? frontMatricPic,
    File? backMatricPic,
    File? passportMyKadPic,
  ) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      final prefs2 = await SharedPreferences.getInstance();
      String? storedStudentId = prefs2.getString('studentID') as String;

      // Create CheckInApplication with placeholder
      CheckInApplication newApplication = CheckInApplication(
          checkInApplicationDate: DateTime.now(),
          checkInApplicationId: '', // Placeholder
          checkInDate: checkInDate,
          studentId: storedStudentId, // Link to the student
          checkInStatus: 'Pending',
          duration: duration, // 1 month for short term, 3 month for long term
          roomType: roomType, // Default to single room
          price: price // Placeholder
          );

      //int calculatedPrice = newApplication.calculatePrice();

      // Add to Firestore; gets auto-generated ID
      DocumentReference docRef = await _firestore
          .collection('CheckInApplications')
          .add(newApplication.toMap());

      // Update the checkInApplicationId
      await docRef.update({'checkInApplicationId': docRef.id});

      await _firestore.collection('Students').doc(storedStudentId).update({
        'studentFirstName': firstName,
        'studentLastName': lastName,
        'studentmyKadPassportNumber': passportNo,
        'studentPhoneNumber': phoneNo,
        'studentNationality': nationality,
        'studentDoB': dateofBirth,
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

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const StudentHomePage()));
    } on FirebaseException {
    } catch (e) {
      // ... Generic errors
    }
  }

  Future<Student?> fetchStudentData(CheckInApplication application) async {
    try {
      final _firestore = FirebaseFirestore.instance;

      // Fetch student document based on studentId
      DocumentSnapshot studentSnapshot = await _firestore
          .collection('Students')
          .doc(application.studentId)
          .get();

      // Check if student document exists
      if (studentSnapshot.exists) {
        return Student.fromFirestore(studentSnapshot);
      } else {
        return null;
      }
    } on FirebaseException {
      // Handle Firestore errors
      return null;
    } catch (e) {
      // Handle generic errors
      return null;
    }
  }

  Future<List<CheckInApplication>>
      fetchCheckInApplicationsWithStudents() async {
    try {
      final _firestore = FirebaseFirestore.instance;

      // 1. Fetch check-in applications
      QuerySnapshot applicationsSnapshot =
          await _firestore.collection('CheckInApplications').get();

      List<CheckInApplication> applications = applicationsSnapshot.docs
          .map((doc) => CheckInApplication.fromFirestore(doc))
          .toList();

      // 2. Get unique student IDs
      Set<String> studentIds = applications.map((app) => app.studentId).toSet();

      // 3. Fetch student data in bulk
      QuerySnapshot studentsSnapshot = await _firestore
          .collection('Students')
          .where('studentId', whereIn: studentIds.toList())
          .get();

      var studentMap = {
        for (var doc in studentsSnapshot.docs)
          (doc.data() as Map<String, dynamic>)['studentId'] as String:
              Student.fromFirestore(doc as DocumentSnapshot<Object?>)
      };

      // 4. Attach student data to applications
      for (var application in applications) {
        application.student = studentMap[application.studentId];
      }

      return applications;
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
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
