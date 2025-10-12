class FavoriteCar {
  final int carId;
  final String carName;
  final String carBrand;
  final String carDescription;
  final String carCategory;
  final double rentPrice;
  final DateTime dateAdded;
  final String? imageData1;
  final String? imageData2;
  final String? imageData3;
  final String status;

  FavoriteCar({
    required this.carId,
    required this.carName,
    required this.carBrand,
    required this.carDescription,
    required this.carCategory,
    required this.rentPrice,
    required this.dateAdded,
    this.imageData1,
    this.imageData2,
    this.imageData3,
    required this.status,
  });

  factory FavoriteCar.fromJson(Map<String, dynamic> json) {
    return FavoriteCar(
      carId: int.tryParse(json['carId'].toString()) ?? 0,
      carName: json['car_name'].toString(),
      carBrand: json['car_brand'].toString(),
      carDescription: json['car_description'].toString(),
      carCategory: json['car_category'].toString(),
      rentPrice: double.tryParse(json['rent_price'].toString()) ?? 0.0,
      dateAdded: DateTime.parse(json['date_added'].toString()),
      imageData1: json['image_data1']?.toString(),
      imageData2: json['image_data2']?.toString(),
      imageData3: json['image_data3']?.toString(),
      status: json['status'].toString(),
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
      'image_data1': imageData1,
      'image_data2': imageData2,
      'image_data3': imageData3,
      'status': status,
    };
  }
}
