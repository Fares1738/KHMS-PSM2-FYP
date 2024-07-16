import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khms/Model/Announcement.dart';


class AnnouncementController {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Announcements');

  Future<List<Announcement>> fetchAnnouncements() async {
    QuerySnapshot snapshot = await _collectionRef.get();
    return snapshot.docs.map((doc) {
      return Announcement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> uploadAnnouncement({
    required String title,
    required String description,
    String? imageUrl,
    XFile? imageFile,
  }) async {
    String uploadedImageUrl = imageUrl ?? '';

    if (imageFile != null) {
      String fileName = imageFile.name;
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      uploadedImageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    await _collectionRef.add({
      'title': title,
      'description': description,
      'imageUrl': uploadedImageUrl,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> removeAnnouncement(String id) async {
    await _collectionRef.doc(id).delete();
  }
}
