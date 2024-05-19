// ignore_for_file: file_names

import 'package:khms/Model/Room.dart';

List<Room> generateRoomsForBlock(String blockName) {
  List<Room> rooms = [];

  for (int floor = 1; floor <= 8; floor++) {
    int startingRoomNumber = floor * 100 + 1; 
    int endingRoomNumber = startingRoomNumber + 25;

    for (int roomNumber = startingRoomNumber; roomNumber <= endingRoomNumber; roomNumber++) {
      String roomType;
      if (roomNumber <= startingRoomNumber + 18) {
        roomType = 'Single';
      } else if (roomNumber <= startingRoomNumber + 22) {
        roomType = 'Double';
      } else {
        roomType = 'Triple';
      }

      rooms.add(
        Room(
          '$blockName$roomNumber', 
          roomType,
          true, 
          floor,  // Include floor number
        ),
      );
    }
  }

  return rooms;
}
