// ignore_for_file: file_names

import 'package:khms/Model/User.dart';

class Student extends User {
  DateTime studentDoB;
  String studentEmail;
  String studentFirstName;
  String studentLastName;
  String studentId;
  String studentNationality;
  String studentmyKadPassportNumber;
  int studentPhoneNumber;
  String studentIcNumber;
  String studentPhoto;
  String studentMatricNo;
  String studentMatricPhoto;
  String studentRoomNo;

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
      {required super.userName,
      required super.userPassword,
      required super.userType,
      required this.studentId});

  Map<String, dynamic> toMap() {
    return {
      'studentEmail': studentEmail,
      'userName': userName,
      'userPassword': userPassword,
      'userType': userType,
      'studentId' : studentId
    };
  }
}
