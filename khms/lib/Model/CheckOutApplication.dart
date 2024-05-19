// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Student.dart';

class CheckOutApplication {
  DateTime checkOutApplicationDate;
  String checkOutApplicationId;
  DateTime checkOutDate;
  String checkOutStatus;
  DateTime? checkOutTime;
  String studentId;
  Student? student;

  CheckOutApplication({
    required this.checkOutApplicationDate,
    required this.checkOutApplicationId,
    required this.checkOutDate,
    required this.checkOutStatus,
    this.checkOutTime,
    required this.studentId,
    this.student,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkOutApplicationDate': checkOutApplicationDate,
      'checkOutApplicationId': checkOutApplicationId,
      'checkOutDate': checkOutDate,
      'checkOutStatus': checkOutStatus,
      'studentId': studentId,
    };
  }

  CheckOutApplication.fromFirestore(DocumentSnapshot document)
      : checkOutApplicationDate = ((document.data()
                    as Map<String, dynamic>)['checkOutApplicationDate']
                as Timestamp)
            .toDate(),
        checkOutApplicationId = (document.data()
            as Map<String, dynamic>)['checkOutApplicationId'] as String,
        checkOutDate = ((document.data()
                as Map<String, dynamic>)['checkOutDate'] as Timestamp)
            .toDate(),
        studentId =
            (document.data() as Map<String, dynamic>)['studentId'] as String,
        checkOutStatus = (document.data()
            as Map<String, dynamic>)['checkOutStatus'] as String,
        checkOutTime =
            (document.data() as Map<String, dynamic>)['checkOutTime'] != null
                ? ((document.data() as Map<String, dynamic>)['checkOutTime']
                        as Timestamp)
                    .toDate()
                : null;
}
