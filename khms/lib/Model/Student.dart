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
  late String studentPhoto;
  String studentMatricNo;
  late String studentMatricPhoto;
  late String studentRoomNo;

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
      this.studentMatricPhoto,
      this.studentRoomNo,
      {required this.studentId,
      required userType});

  Map<String, dynamic> toMap() {
    return {
      'studentEmail': studentEmail,
      'userType': "Student",
      'studentId': studentId,
      'studentFirstName': studentFirstName,
      'studentLastName': studentLastName,
      'studentNationality': studentNationality,
      'studentmyKadPassportNumber': studentmyKadPassportNumber,
      'studentPhoneNumber': studentPhoneNumber,
      'studentIcNumber': studentIcNumber,
      'studentPhoto': studentPhoto,
      'studentMatricNo': studentMatricNo,
      'studentMatricPhoto': studentMatricPhoto,
      'studentRoomNo': studentRoomNo,
    };
  }

  Student.fromFirestore(DocumentSnapshot document)
      : studentDoB = ((document.data() as Map<String, dynamic>)['studentDoB']
                as Timestamp)
            .toDate(),
        studentEmail =
            (document.data() as Map<String, dynamic>)['studentEmail'] as String,
        studentFirstName = (document.data()
            as Map<String, dynamic>)['studentFirstName'] as String,
        studentLastName = (document.data()
            as Map<String, dynamic>)['studentLastName'] as String,
        studentNationality = (document.data()
            as Map<String, dynamic>)['studentNationality'] as String,
        studentmyKadPassportNumber = (document.data()
            as Map<String, dynamic>)['studentmyKadPassportNumber'] as String,
        studentPhoneNumber = (document.data()
            as Map<String, dynamic>)['studentPhoneNumber'] as String,
        studentIcNumber = (document.data()
            as Map<String, dynamic>)['studentIcNumber'] as String,
        // studentPhoto = (document.data()
        //     as Map<String, dynamic>)['passportMyKadImage'] as String,
        studentMatricNo = (document.data()
            as Map<String, dynamic>)['studentMatricNo'] as String,
        // studentMatricPhoto = (document.data()
        //     as Map<String, dynamic>)['frontMatricCardImage'] as String,
        // studentRoomNo = (document.data()
        //     as Map<String, dynamic>)['studentRoomNo'] as String,
        studentId =
            (document.data() as Map<String, dynamic>)['studentId'] as String;
}
