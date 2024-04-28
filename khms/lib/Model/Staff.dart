// ignore_for_file: file_names

import 'package:khms/Model/User.dart';

class Staff extends User {
  String staffEmail;
  String staffFirstName;
  String staffId;
  String staffLastName;

  Staff(
      {required this.staffEmail,
      required this.staffFirstName,
      required this.staffId,
      required this.staffLastName,
      required super.userName,
      required super.userPassword,
      required super.userType});
}
