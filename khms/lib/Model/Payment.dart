// ignore_for_file: file_names

import 'dart:ffi';

import 'package:khms/Model/Student.dart';

class Payment {
  Double paymentAmount;
  DateTime paymentDate;
  String paymentId;
  String paymentType;
  Student studentId;

  Payment(
      {required this.paymentAmount,
      required this.paymentDate,
      required this.paymentId,
      required this.paymentType,
      required this.studentId});
}
