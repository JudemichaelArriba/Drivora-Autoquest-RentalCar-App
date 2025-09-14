class Car {
  final int carId;
  final String carName;
  final String carBrand;
  final String carDescription;
  final String carCategory;
  final double rentPrice;
  final DateTime dateAdded;
  final double rating;
  final String? imageBase64;

  Car({
    required this.carId,
    required this.carName,
    required this.carBrand,
    required this.carDescription,
    required this.carCategory,
    required this.rentPrice,
    required this.dateAdded,
    required this.rating,
    this.imageBase64,
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

      rating: double.parse(json['rating'].toString()),
      imageBase64: json['image_data']?.toString(),
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

      'rating': rating,
      'image_base64': imageBase64,
    };
  }
}
