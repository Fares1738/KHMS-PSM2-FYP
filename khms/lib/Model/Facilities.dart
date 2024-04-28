// ignore_for_file: file_names

import 'package:khms/Model/Student.dart';

class Facilities {
  DateTime facilityApplicationDate;
  int facilityApplicationId;
  DateTime facilityStartTime;
  DateTime facilityEndTime;
  String facilityType;
  bool facilityAvailability;
  Student studentId;
  Student studentRoomNo;

  Facilities({
    required this.facilityApplicationDate,
    required this.facilityApplicationId,
    required this.facilityStartTime,
    required this.facilityEndTime,
    required this.facilityType,
    required this.facilityAvailability,
    required this.studentId,
    required this.studentRoomNo,
  });
}
