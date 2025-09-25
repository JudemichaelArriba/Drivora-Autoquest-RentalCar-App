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

  Future<List<dynamic>> getFavoriteCars() async {
    try {
      final data = await api.getData('get_favorite_cars.php');
      return data;
    } catch (e) {
      throw Exception('Failed to fetch favorite cars: $e');
    }
  }

  Future<String> bookCar({
    required String uid,
    required int carId,
    required String startDate,
    required String endDate,
    required double totalPrice,
  }) async {
    try {
      final response = await api.postData('addBooking.php', {
        'uid': uid,
        'carId': carId.toString(),
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice.toString(),
      });

      if (response['success'] == true) {
        return response['bookingId'];
      } else {
        throw Exception(response['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }
}
