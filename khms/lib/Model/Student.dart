// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  DateTime studentDoB;
  String studentEmail;
  String studentFirstName;
  String studentLastName;
  String? studentId;
  String studentNationality;
  String studentmyKadPassportNumber;
  String studentPhoneNumber;
  String studentIcNumber;
  String studentPhoto;
  String studentMatricNo;
  String studentRoomNo;
  String backMatricPic;
  String frontMatricPic;
  String passportMyKadPic;

  Student(
    this.studentDoB,
    this.studentEmail,
    this.studentFirstName,
    this.studentLastName,
    this.studentNationality,
    this.studentmyKadPassportNumber,
    this.studentPhoneNumber,
    this.studentIcNumber,
    this.studentPhoto,
    this.studentMatricNo,
    this.studentRoomNo,
    this.backMatricPic,
    this.frontMatricPic,
    this.passportMyKadPic, {
    this.studentId,
    userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentDoB': studentDoB.toIso8601String(),
      'studentEmail': studentEmail,
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'studentNationality': studentNationality,
      'studentmyKadPassportNumber': studentmyKadPassportNumber,
      'studentPhoneNumber': studentPhoneNumber,
      'studentIcNumber': studentIcNumber,
      'studentPhoto': studentPhoto,
      'studentMatricNo': studentMatricNo,
      'studentRoomNo': studentRoomNo,
      'backMatricPic': backMatricPic,
      'frontMatricPic': frontMatricPic,
      'passportMyKadPic': passportMyKadPic,
      'studentId': studentId,
    };
  }

  Student.fromJson(Map<String, dynamic> json)
      : studentDoB = DateTime.parse(json['studentDoB']),
        studentEmail = json['studentEmail'],
        studentFirstName = json['studentFirstName'],
        studentLastName = json['studentLastName'],
        studentNationality = json['studentNationality'],
        studentmyKadPassportNumber = json['studentmyKadPassportNumber'],
        studentPhoneNumber = json['studentPhoneNumber'],
        studentIcNumber = json['studentIcNumber'],
        studentPhoto = json['studentPhoto'],
        studentMatricNo = json['studentMatricNo'],
        studentRoomNo = json['studentRoomNo'],
        backMatricPic = json['backMatricPic'],
        frontMatricPic = json['frontMatricPic'],
        passportMyKadPic = json['passportMyKadPic'],
        studentId = json['studentId'];

  Map<String, dynamic> toMap() {
    return {
      'studentEmail': studentEmail,
      'userType': "Students",
      'studentId': studentId,
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'studentNationality': studentNationality,
      'studentmyKadPassportNumber': studentmyKadPassportNumber,
      'studentPhoneNumber': studentPhoneNumber,
      'studentIcNumber': studentIcNumber,
      'studentPhoto': studentPhoto,
      'studentMatricNo': studentMatricNo,
      'studentRoomNo': studentRoomNo,
      'backMatricCardImage': backMatricPic,
      'frontMatricCardImage': frontMatricPic,
      'passportMyKadImage': passportMyKadPic
    };
  }

  Student.fromFirestore(DocumentSnapshot document)
      : studentDoB =
            (document.data() as Map<String, dynamic>)['studentDoB'] != null
                ? ((document.data() as Map<String, dynamic>)['studentDoB']
                        as Timestamp)
                    .toDate()
                : DateTime.now(),
        studentEmail =
            (document.data() as Map<String, dynamic>)['studentEmail'] ?? '',
        studentFirstName =
            (document.data() as Map<String, dynamic>)['studentFirstName'] ?? '',
        studentLastName =
            (document.data() as Map<String, dynamic>)['studentLastName'] ?? '',
        studentNationality =
            (document.data() as Map<String, dynamic>)['studentNationality'] ??
                '',
        studentmyKadPassportNumber = (document.data()
                as Map<String, dynamic>)['studentmyKadPassportNumber'] ??
            '',
        studentPhoneNumber =
            (document.data() as Map<String, dynamic>)['studentPhoneNumber'] ??
                '',
        studentIcNumber =
            (document.data() as Map<String, dynamic>)['studentIcNumber'] ?? '',
        studentPhoto =
            (document.data() as Map<String, dynamic>)['studentPhoto'] ?? '',
        studentMatricNo =
            (document.data() as Map<String, dynamic>)['studentMatricNo'] ?? '',
        studentRoomNo =
            (document.data() as Map<String, dynamic>)['studentRoomNo'] ?? '',
        studentId =
            (document.data() as Map<String, dynamic>)['studentId'] ?? '',
        backMatricPic =
            (document.data() as Map<String, dynamic>)['backMatricCardImage'] ??
                '',
        frontMatricPic =
            (document.data() as Map<String, dynamic>)['frontMatricCardImage'] ??
                '',
        passportMyKadPic =
            (document.data() as Map<String, dynamic>)['passportMyKadImage'] ??
                '';
}
