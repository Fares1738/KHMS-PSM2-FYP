// ignore_for_file: use_build_context_synchronously, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Model/Complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/View/Student/studentMainPage.dart';
import 'package:khms/api/firebase_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ComplaintsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitComplaint(
      BuildContext context, Complaint complaint, File? imageFile) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('userId') as String;

      complaint.studentId = storedStudentId;

      if (imageFile != null) {
        final imageUrl = await _uploadImageToFirebase(imageFile);
        complaint.complaintImageUrl = imageUrl;
      }

      DocumentReference docRef =
          await firestore.collection('Complaints').add(complaint.toMap());
      await docRef.update({'complaintId': docRef.id});

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Complaint Submitted!")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentMainPage()),
      );
    } catch (e) {
      print('Error submitting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error submitting complaint.")));
    }
  }

  Future<List<Complaint>> fetchAllComplaints() async {
    final collection = _firestore.collection('Complaints');
    final querySnapshot = await collection.get();

    return querySnapshot.docs.map((doc) {
      return Complaint.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateComplaintStatus(
      String complaintId, ComplaintStatus status) async {
    await _firestore.collection('Complaints').doc(complaintId).update({
      'complaintStatus': status.name,
    });
    FirebaseApi.sendNotification(
        'Complaints',
        complaintId,
        'Complaint Status is ${status.name}',
        'Your complaint status has been ${status.name}. Check the app for more details.');
  }

  Future<String> _uploadImageToFirebase(File image) async {
    String fileName = DateTime.now().toString();

    final storageRef =
        FirebaseStorage.instance.ref().child('complaints/$fileName');

    final UploadTask uploadTask = storageRef.putFile(image);

    final TaskSnapshot downloadSnapshot =
        await uploadTask.whenComplete(() => null);

    final String downloadUrl = await downloadSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<List<Complaint>> fetchComplaints(String studentId) async {
    final collection = FirebaseFirestore.instance.collection('Complaints');
    final querySnapshot =
        await collection.where('studentId', isEqualTo: studentId).get();

    return querySnapshot.docs.map((doc) {
      return Complaint.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<String> fetchStudentRoomNumber() async {
    final prefs4 = await SharedPreferences.getInstance();
    String? studentRoomNo = prefs4.getString('studentRoomNo');

    if (studentRoomNo == null) {
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('userId') as String;

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(storedStudentId)
          .get();

      studentRoomNo = studentDoc.data()!['studentRoomNo'];
    }

    return studentRoomNo!;
  }
}
