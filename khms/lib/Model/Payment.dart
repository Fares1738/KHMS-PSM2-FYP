// ignore_for_file: file_names

class Payment {
  double paymentAmount;
  DateTime paymentDate;
  String paymentId;
  String paymentType;
  String cardNumber;
  String expiryDate;
  String cvc;
  String name;

  Payment({
    required this.paymentAmount,
    required this.paymentDate,
    required this.paymentId,
    required this.paymentType,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvc,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'paymentAmount': paymentAmount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentId': paymentId,
      'paymentType': paymentType,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvc': cvc,
      'name': name,
    };
  }

  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentAmount: map['paymentAmount'],
      paymentDate: DateTime.parse(map['paymentDate']),
      paymentId: map['paymentId'],
      paymentType: map['paymentType'],
      cardNumber: map['cardNumber'],
      expiryDate: map['expiryDate'],
      cvc: map['cvc'],
      name: map['name'],
    );
  }
}
