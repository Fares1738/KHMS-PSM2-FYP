// ignore_for_file: file_names

import 'package:khms/Model/Student.dart';

class CheckOutApplication {
  DateTime checkOutApplicationDate;
  int checkOutApplicationId;
  DateTime checkOutDate;
  String checkOutStatus;
  String checkOutTime;
  Student studentId;

  CheckOutApplication({
    required this.checkOutApplicationDate,
    required this.checkOutApplicationId,
    required this.checkOutDate,
    required this.checkOutStatus,
    required this.checkOutTime,
    required this.studentId,
  });
}
