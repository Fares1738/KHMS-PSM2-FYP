// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Room.dart';

class Block {
  String blockName;
  int blockNoOfRooms;
  List<Room> rooms;

  Block(
      {required this.blockName,
      required this.blockNoOfRooms,
      required this.rooms});

  Block.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : blockName = doc.data()!['blockName'],
        blockNoOfRooms = doc.data()!['blockNoOfRooms'],
        rooms = [];
}
