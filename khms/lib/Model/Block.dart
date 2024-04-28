// ignore_for_file: file_names

import 'package:khms/Model/Room.dart';

class Block {
  String blockName;
  int blockNoOfRooms;
  Room room;

  Block(
      {required this.blockName,
      required this.blockNoOfRooms,
      required this.room});
}
