// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, empty_catches, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khms/Model/Block.dart';
import 'package:khms/Model/CheckInApplication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Room.dart';
import 'package:khms/Model/Student.dart';
import 'package:khms/View/Student/studentMainPage.dart';
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
  ) async {
    try {
      final _firestore = FirebaseFirestore.instance;
      final prefs2 = await SharedPreferences.getInstance();
      String? storedStudentId = prefs2.getString('studentID') as String;

      // Create CheckInApplication with placeholder
      CheckInApplication newApplication = CheckInApplication(
          checkInApplicationDate: DateTime.now(),
          checkInApplicationId: checkInApplicationId ?? '',
          checkInDate: checkInDate,
          studentId: storedStudentId,
          checkInStatus: 'Pending',
          roomType: roomType,
          price: price,
          rejectionReason: '');

      // Add to Firestore; gets auto-generated ID

      if (checkInApplicationId == null) {
        DocumentReference docRef = await _firestore
            .collection('CheckInApplications')
            .add(newApplication.toMap());

        await docRef.update({'checkInApplicationId': docRef.id});
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

      String studentName = '$firstName $lastName';

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentMainPage(studentName: studentName)));
    } on FirebaseException {
    } catch (e) {
      // ... Generic errors
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
        .snapshots() // Listen for changes in the CheckInApplications collection
        .asyncMap((applicationsSnapshot) async {
      // Use asyncMap to handle async operations within the stream

      final applications = applicationsSnapshot.docs
          .map((doc) => CheckInApplication.fromFirestore(doc))
          .toList();

      // Fetch student data in parallel using a map
      final studentIds = applications
          .map((app) => app.studentId)
          .toSet(); // Unique student IDs
      final studentsFutureMap = {
        for (var studentId in studentIds)
          studentId: _firestore.collection('Students').doc(studentId).get()
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

  Future<int> getAssignedTenantsCount(String roomNo) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('CheckInApplications')
          .where('roomNo', isEqualTo: roomNo)
          .where('checkInStatus', isEqualTo: 'Approved')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      // Handle errors (e.g., log, show error message)
      print('Error getting assigned tenants: $e');
      return 0;
    }
  }

  Future<void> updateCheckInApplication(CheckInApplication application,
      String newStatus, String? roomNo, String? rejectionReason) async {
    try {
      final firestore = FirebaseFirestore.instance;

      WriteBatch batch = firestore.batch(); // Use a batch for atomic updates

      // Update the check-in application document
      Map<String, dynamic> updateData = {
        'checkInStatus': newStatus,
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
          updateData);

      batch.update(
        firestore.collection('Students').doc(application.studentId),
        {'studentRoomNo': roomNo},
      );

      // Update room availability if a room is assigned and approved
      if (newStatus == 'Approved' && roomNo != null) {
        // Find the corresponding block document
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

      await batch.commit(); // Commit both updates as a single transaction
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

  Future<Room?> assignRoom(String roomType, List<Block> blocks) async {
    for (var floor = 8; floor >= 1; floor--) {
      // Iterate floors in descending order
      for (var block in blocks) {
        for (var room in block.rooms.where((r) => r.floorNumber == floor)) {
          if (room.roomType == roomType) {
            if (roomType == 'Single' && room.roomAvailability) {
              room.roomAvailability = false;
              await updateRoomAvailability(block, room);
              return room;
            } else if (roomType != 'Single') {
              if (room.roomAvailability) {
                final assignedStudents = await _firestore
                    .collection('CheckInApplications')
                    .where('roomNo', isEqualTo: room.roomNo)
                    .where('checkinStatus', isEqualTo: 'Approved')
                    .get();
                final numAssigned = assignedStudents.docs.length;
                if (numAssigned < int.parse(roomType[0])) {
                  if (numAssigned + 1 == int.parse(roomType[0])) {
                    room.roomAvailability = false;
                    await updateRoomAvailability(block, room);
                  }
                  return room;
                }
              }
            }
          }
        }
      }
    }
    return null;
  }

  Future<void> updateRoomAvailability(Block block, Room room) async {
    await _firestore
        .collection('Blocks')
        .doc(block.blockName) // Assuming you store blocks by name
        .update({
      'rooms': block.rooms.map((r) => r.toMap()).toList(),
    });
  }
}
