// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  String roomNo;
  String roomType; // Single, Double, Triple
  bool roomAvailability;
  int floorNumber;

  Room(this.roomNo, this.roomType, this.roomAvailability, this.floorNumber);

  Map<String, dynamic> toMap() {
    return {
      'roomNo': roomNo,
      'roomType': roomType,
      'roomAvailability': roomAvailability,
      'floorNumber': floorNumber,
    };
  }

  Room.fromMap(Map<String, dynamic> map)
      : roomNo = map['roomNo'],
        roomType = map['roomType'],
        roomAvailability = map['roomAvailability'],
        floorNumber = map['floorNumber'];

  Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : roomNo = doc.id,
        roomType = doc.data()!['roomType'],
        roomAvailability = doc.data()!['roomAvailability'],
        floorNumber = doc.data()!['floorNumber'];

  @override
  bool operator ==(Object other) {
    return other is Room &&
        other.roomNo == roomNo &&
        other.roomType == roomType &&
        other.roomAvailability == roomAvailability &&
        other.floorNumber == floorNumber;
  }

  @override
  int get hashCode =>
      Object.hash(roomNo, roomType, roomAvailability, floorNumber);
}
