import 'package:drivora_autoquest/services/api_connection.dart';

class CarService {
  final ApiService api;

  CarService({required this.api});

  Future<List<dynamic>> getCars() async {
    try {
      final data = await api.getData('get_cars.php');
      return data;
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }
}
