// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInApplication {
  DateTime checkInApplicationDate;
  String checkInApplicationId;
  String checkInDate;
  String studentId;
  String checkInStatus;

  CheckInApplication(
      {required this.checkInApplicationDate,
      required this.checkInApplicationId,
      required this.checkInDate,
      required this.studentId,
      required this.checkInStatus});

  Map<String, dynamic> toMap() {
    return {
      'checkInApplicationDate': Timestamp.fromDate(checkInApplicationDate),
      'checkInApplicationId': checkInApplicationId,
      'checkInDate': checkInDate,
      'studentId': studentId,
      'checkInStatus': checkInStatus,
    };
  }
}
