class Booking {
  final String bookingId;
  final String uid;
  final int carId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.bookingId,
    required this.uid,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['bookingId'].toString(),
      uid: json['uid'].toString(),
      carId: int.tryParse(json['carId'].toString()) ?? 0,
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'uid': uid,
      'carId': carId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
