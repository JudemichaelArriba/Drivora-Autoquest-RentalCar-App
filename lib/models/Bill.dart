class Bill {
  final int billId;
  final String bookingId;
  final String uid;
  final int carId;
  final double amount;
  final String paymentStatus;
  final DateTime issuedAt;
  final DateTime updatedAt;

  Bill({
    required this.billId,
    required this.bookingId,
    required this.uid,
    required this.carId,
    required this.amount,
    required this.paymentStatus,
    required this.issuedAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: int.tryParse(json['billId'].toString()) ?? 0,
      bookingId: json['bookingId'].toString(),
      uid: json['uid'].toString(),
      carId: int.tryParse(json['carId'].toString()) ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentStatus: json['payment_status'].toString(),
      issuedAt: DateTime.parse(json['issued_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'bookingId': bookingId,
      'uid': uid,
      'carId': carId,
      'amount': amount,
      'payment_status': paymentStatus,
      'issued_at': issuedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
