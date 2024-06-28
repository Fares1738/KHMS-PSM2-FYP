// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Student.dart';

class Facilities {
  String facilityApplicationId;
  DateTime facilityApplicationDate;
  String? facilitySlot;
  String facilityType;
  String studentId;
  Student? student;
  String? studentRoomNo;
  String facilityApplicationStatus;

  Facilities({
    required this.facilityApplicationId,
    required this.facilityApplicationDate,
    required this.facilitySlot,
    required this.facilityType,
    required this.studentId,
     this.studentRoomNo,
    required this.facilityApplicationStatus,
    this.student
  });

  // Update toMap method
  Map<String, dynamic> toMap() {
    return {
      'facilityApplicationId': facilityApplicationId,
      'facilityApplicationDate': facilityApplicationDate,
      'facilitySlot': facilitySlot,
      'facilityType': facilityType,
      'studentId': studentId,
      'studentRoomNo': studentRoomNo,
      'facilityStatus': facilityApplicationStatus,
    };
  }

  factory Facilities.fromMap(Map<String, dynamic> map) {
    return Facilities(
        facilityApplicationId: map['facilityApplicationId'] as String? ?? '',
        facilityApplicationDate:
            (map['facilityApplicationDate'] as Timestamp).toDate(),
        facilitySlot: map['facilitySlot'] as String?,
        facilityType: map['facilityType'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        studentRoomNo: map['studentRoomNo'] as String? ?? '',
        facilityApplicationStatus:
            map['facilityStatus'] as String? ?? 'Pending');
  }
}
