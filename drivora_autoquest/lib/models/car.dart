class Car {
  final int carId;
  final String carName;
  final String carBrand;
  final String carDescription;
  final String carCategory;
  final double rentPrice;
  final DateTime dateAdded;
  final String? imageBase64_1;
  final String? imageBase64_2;
  final String? imageBase64_3;
  final String status; // "Booked" or "Available"
  final bool favorites;

  Car({
    required this.carId,
    required this.carName,
    required this.carBrand,
    required this.carDescription,
    required this.carCategory,
    required this.rentPrice,
    required this.dateAdded,
    this.imageBase64_1,
    this.imageBase64_2,
    this.imageBase64_3,
    required this.status,
    required this.favorites,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: int.parse(json['carId'].toString()),
      carName: json['car_name'].toString(),
      carBrand: json['car_brand'].toString(),
      carDescription: json['car_description'].toString(),
      carCategory: json['car_category'].toString(),
      rentPrice: double.parse(json['rent_price'].toString()),
      dateAdded: DateTime.parse(json['date_added'].toString()),
      imageBase64_1: json['image_data1']?.toString(),
      imageBase64_2: json['image_data2']?.toString(),
      imageBase64_3: json['image_data3']?.toString(),
      status: json['status'].toString(),
      favorites:
          json['favorites'].toString() == '1' ||
          json['favorites'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carId': carId,
      'car_name': carName,
      'car_brand': carBrand,
      'car_description': carDescription,
      'car_category': carCategory,
      'rent_price': rentPrice,
      'date_added': dateAdded.toIso8601String(),
      'image_data1': imageBase64_1,
      'image_data2': imageBase64_2,
      'image_data3': imageBase64_3,
      'status': status,
      'favorites': favorites,
    };
  }
}
