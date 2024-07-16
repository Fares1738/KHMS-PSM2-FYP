// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khms/Model/Student.dart';

class CheckInApplication {
  DateTime checkInApplicationDate;
  String checkInApplicationId;
  DateTime checkInDate;
  String studentId;
  String checkInStatus;
  String? roomType;
  int? price;
  Student? student;
  String? rejectionReason;
  bool? isPaid;
  DateTime? checkInApprovalDate;

  CheckInApplication({
    required this.checkInApplicationDate,
    required this.checkInApplicationId,
    required this.checkInDate,
    required this.studentId,
    required this.checkInStatus,
    required this.roomType,
    required this.price,
    required this.isPaid,
    this.rejectionReason = '',
    this.checkInApprovalDate,
    
  });

  int calculatePrice() {
    final prices = {'Single': 760, 'Double': 630, 'Triple': 520};
    return prices[roomType] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'checkInApplicationDate': Timestamp.fromDate(checkInApplicationDate),
      'checkInApplicationId': checkInApplicationId,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'studentId': studentId,
      'checkInStatus': checkInStatus,
      'roomType': roomType,
      'price': price,
      'rejectionReason': rejectionReason,
      'isPaid': isPaid,
      'checkInApprovalDate': checkInApprovalDate,
    };
  }

CheckInApplication.fromFirestore(DocumentSnapshot document)
    : checkInApplicationDate = ((document.data()
              as Map<String, dynamic>)['checkInApplicationDate'] as Timestamp)
          .toDate(),
      checkInApplicationId = (document.data()
          as Map<String, dynamic>)['checkInApplicationId'] as String,
      checkInDate = ((document.data() as Map<String, dynamic>)['checkInDate']
              as Timestamp)
          .toDate(),
      studentId =
          (document.data() as Map<String, dynamic>)['studentId'] as String,
      checkInStatus = (document.data()
          as Map<String, dynamic>)['checkInStatus'] as String,
      roomType = (document.data() as Map<String, dynamic>)['roomType']
          as String?, 
      price = (document.data() as Map<String, dynamic>)['price']
          as int?, 
      rejectionReason =
          (document.data() as Map<String, dynamic>)['rejectionReason']
              as String, 
      isPaid = (document.data() as Map<String, dynamic>)['isPaid'] as bool,
      checkInApprovalDate = (document.data() as Map<String, dynamic>)
                  .containsKey('checkInApprovalDate')
              ? ((document.data() as Map<String, dynamic>)['checkInApprovalDate']
                  as Timestamp)
                  .toDate()
              : null; 

}
