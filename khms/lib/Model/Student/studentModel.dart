// ignore_for_file: file_names

import 'dart:core';

class StudentModel {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final bool? isChecked;

  StudentModel({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.isChecked,
  });


}