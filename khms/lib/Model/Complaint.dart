// ignore_for_file: file_names

import 'package:khms/Model/Student.dart';

class Complaint {
  DateTime complaintDate;
  String complaintDescription;
  String complaintLocation;
  String complaintStatus;
  String complaintType;
  String complaintSubType;
  String complaintId;
  Student studentId;
  Student studentRoomNo;

  Complaint({
    required this.complaintDate,
    required this.complaintDescription,
    required this.complaintLocation,
    required this.complaintStatus,
    required this.complaintType,
    required this.complaintSubType,
    required this.complaintId,
    required this.studentId,
    required this.studentRoomNo,
  });
}
