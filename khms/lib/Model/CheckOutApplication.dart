// ignore_for_file: file_names 

class CheckOutApplication {
  DateTime checkOutApplicationDate;
  String checkOutApplicationId;
  DateTime checkOutDate;
  String checkOutStatus;
  String checkOutTime;
  String studentId; 

  CheckOutApplication({
    required this.checkOutApplicationDate,
    required this.checkOutApplicationId,
    required this.checkOutDate,
    required this.checkOutStatus,
    required this.checkOutTime,
    required this.studentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'checkOutApplicationDate': checkOutApplicationDate,
      'checkOutApplicationId': checkOutApplicationId,
      'checkOutDate': checkOutDate,
      'checkOutStatus': checkOutStatus,
      'checkOutTime': checkOutTime,
      'studentId': studentId, 
    };
  }
}
