// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Room.dart';
import 'package:khms/View/Custom_Widgets/roomGenerator.dart';

class RoomController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadRoomsToFirestore() async {
    try {
      for (String blockName in ['A', 'B']) {
        final List<Room> rooms = generateRoomsForBlock(blockName);
        final blockRef = _firestore.collection('Blocks').doc('Block $blockName');

        // Create the block document (or overwrite if it exists)
        await blockRef.set({
          'blockName': 'Block $blockName',
          'blockNoOfRooms': rooms.length,
        });

        // Batch write to improve performance
        WriteBatch batch = _firestore.batch();
        for (var room in rooms) {
          batch.set(blockRef.collection('Rooms').doc(room.roomNo), room.toMap());
        }
        await batch.commit(); // Commit the batch of writes
      }

      print('Rooms uploaded successfully!');
    } catch (e) {
      print('Error uploading rooms: $e');
    }
  }
}

