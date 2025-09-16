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

  Future<bool> markAsFavorite(int carId) async {
    try {
      final response = await api.postData('mark_favorite.php', {
        'carId': carId.toString(),
      });

      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to favorite car');
      }
    } catch (e) {
      throw Exception('Error marking favorite: $e');
    }
  }

  Future<bool> unmarkAsFavorite(int carId) async {
    try {
      final response = await api.postData('UnMarkCarAsFavorite.php', {
        'carId': carId.toString(),
      });

      if (response['success'] == true) {
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to unmark favorite car');
      }
    } catch (e) {
      throw Exception('Error unmarking favorite: $e');
    }
  }
}
