// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInApplication {
  DateTime checkInApplicationDate;
  String checkInApplicationId;
  String checkInDate;
  String studentId;
  String checkInStatus;
  int? duration;
  String? roomType;
  int? price;

  CheckInApplication(
      {required this.checkInApplicationDate,
      required this.checkInApplicationId,
      required this.checkInDate,
      required this.studentId,
      required this.checkInStatus,
      required this.duration,
      required this.roomType,
      required this.price});

  int calculatePrice() {
    final shortTermPrices = {
      'Single Room': 760,
      'Double Room': 630,
      'Triple Room': 520
    };

    final longTermPrices = {
      'Single Room': 650,
      'Double Room': 460,
      'Triple Room': 395
    };

    var prices = duration == 3 ? longTermPrices : shortTermPrices;
    return prices[roomType] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'checkInApplicationDate': Timestamp.fromDate(checkInApplicationDate),
      'checkInApplicationId': checkInApplicationId,
      'checkInDate': checkInDate,
      'studentId': studentId,
      'checkInStatus': checkInStatus,
      'duration': duration,
      'roomType': roomType,
      'price': price,
    };
  }
}
