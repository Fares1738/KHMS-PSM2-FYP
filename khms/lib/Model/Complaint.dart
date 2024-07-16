// ignore_for_file: file_names, constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus { Pending, Unresolved, Resolved }

class Complaint {
  DateTime complaintDate;
  String complaintDescription;
  String complaintLocation;
  ComplaintStatus complaintStatus;
  String complaintType;
  String complaintSubType;
  String complaintId;
  String complaintImageUrl;
  String studentId;
  String? studentRoomNo;
  String? complaintNote;

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
    required this.complaintImageUrl,
    this.complaintNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'complaintDate': complaintDate,
      'complaintDescription': complaintDescription,
      'complaintLocation': complaintLocation,
      'complaintStatus': complaintStatus.name,
      'complaintType': complaintType,
      'complaintSubType': complaintSubType,
      'complaintId': complaintId,
      'studentId': studentId,
      'complaintImageUrl': complaintImageUrl,
      'studentRoomNo': studentRoomNo,
      'complaintNote': complaintNote,
    };
  }

  factory Complaint.fromMap(Map<String, dynamic> data, String docId) {
    return Complaint(
      complaintDate: (data['complaintDate'] as Timestamp)
          .toDate(), 
      complaintDescription: data['complaintDescription'],
      complaintLocation: data['complaintLocation'],
      complaintStatus: ComplaintStatus.values.byName(data['complaintStatus']),
      complaintType: data['complaintType'],
      complaintSubType: data['complaintSubType'],
      complaintId: docId, 
      studentId: data['studentId'],
      studentRoomNo: data['studentRoomNo'],
      complaintImageUrl: data['complaintImageUrl'],
      complaintNote: data['complaintNote'],
    );
  }
}
