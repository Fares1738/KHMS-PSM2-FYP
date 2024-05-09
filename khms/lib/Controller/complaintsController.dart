// ignore_for_file: use_build_context_synchronously, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:khms/Model/Complaint.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/View/Student/studentHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ComplaintsController {
  Future<void> submitComplaint(
      BuildContext context, Complaint complaint, File? imageFile) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();
      final String storedStudentId = prefs.getString('studentID') as String;

      complaint.studentId = storedStudentId;
      //complaint.studentRoomNo = '';

      // Image Upload (If an image is provided)
      if (imageFile != null) {
        final imageUrl = await _uploadImageToFirebase(imageFile);
        complaint.complaintImageUrl = imageUrl;
      }

      // Add to Firestore
      DocumentReference docRef =
          await firestore.collection('Complaints').add(complaint.toMap());
      await docRef.update({'complaintId': docRef.id});

      // Success Handling
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Complaint Submitted!")));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } catch (e) {
      print('Error submitting complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error submitting complaint.")));
    }
  }

  // The image upload function
  Future<String> _uploadImageToFirebase(File image) async {
    // Create a unique file name
    String fileName = DateTime.now().toString();

    // Storage reference
    final storageRef =
        FirebaseStorage.instance.ref().child('complaints/$fileName');

    // Upload task
    final UploadTask uploadTask = storageRef.putFile(image);

    // Wait for upload completion
    final TaskSnapshot downloadSnapshot =
        await uploadTask.whenComplete(() => null);

    // Get download URL
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
      final String storedStudentId = prefs.getString('studentID') as String;

      final studentDoc = await FirebaseFirestore.instance
          .collection('Students')
          .doc(storedStudentId)
          .get();

      studentRoomNo = studentDoc.data()!['studentRoomNo'];
    }

    return studentRoomNo!;
  }
}
