
class Facilities {
  String facilityApplicationId; 
  DateTime facilityApplicationDate;
  String facilitySlot; 
  String facilityType;
  bool facilityAvailability;
  String studentId;
  String studentRoomNo;
  

  Facilities({
    required this.facilityApplicationId,
    required this.facilityApplicationDate,
    required this.facilitySlot, 
    required this.facilityType,
    required this.facilityAvailability,
    required this.studentId,
    required this.studentRoomNo,
  });

  // Update toMap method
  Map<String, dynamic> toMap() {
    return {
      'facilityApplicationId': facilityApplicationId,
      'facilityApplicationDate': facilityApplicationDate,
      'facilitySlot': facilitySlot, 
      'facilityType': facilityType,
      'facilityAvailability': facilityAvailability,
      'studentId': studentId,
      'studentRoomNo': studentRoomNo,
    };
  }
}
