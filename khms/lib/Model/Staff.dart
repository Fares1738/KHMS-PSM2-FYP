// ignore_for_file: file_names, constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { Manager, Staff, Maintenance }

class Staff {
  String staffFirstName;
  String staffLastName;
  String staffEmail;
  String staffId;
  String staffPhoneNumber;
  String? staffPhoto;
  UserType userType;

  Staff({
    required this.staffEmail,
    required this.staffFirstName,
    required this.staffId,
    required this.staffLastName,
    required this.staffPhoneNumber,
    required this.userType,
    this.staffPhoto
  });

  Map<String, dynamic> toMap() {
    return {
      'staffFirstName': staffFirstName,
      'staffLastName': staffLastName,
      'staffEmail': staffEmail,
      'staffId': staffId,
      'staffPhoneNumber': staffPhoneNumber,
      'userType': userType.toString().split('.').last, 
      'staffPhoto': staffPhoto ?? '',
    };
  }

  factory Staff.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Staff(
      staffFirstName: data['staffFirstName'],
      staffLastName: data['staffLastName'],
      staffEmail: data['staffEmail'],
      staffId: data['staffId'],
      staffPhoneNumber: data['staffPhoneNumber'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == data['userType'],
        orElse: () => UserType.Staff, 
      ),
      staffPhoto: data['staffPhoto'],
    );
  }

  static Staff? fromJson(Map<String, dynamic> userMap) {
    if (userMap.isEmpty) {
      return null;
    }
    return Staff(
      staffFirstName: userMap['staffFirstName'],
      staffLastName: userMap['staffLastName'],
      staffEmail: userMap['staffEmail'],
      staffId: userMap['staffId'],
      staffPhoneNumber: userMap['staffPhoneNumber'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == userMap['userType'],
        orElse: () => UserType.Staff, 
      ),
      staffPhoto: userMap['staffPhoto'],
    );
  }

  toJson() {
    return {
      'staffFirstName': staffFirstName,
      'staffLastName': staffLastName,
      'staffEmail': staffEmail,
      'staffId': staffId,
      'staffPhoneNumber': staffPhoneNumber,
      'userType': userType.toString().split('.').last,
      'staffPhoto': staffPhoto ?? '',
    };
  }
}
