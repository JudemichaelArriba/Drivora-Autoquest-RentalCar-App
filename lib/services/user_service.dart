import 'dart:io';
import 'dart:convert';
import 'package:drivora_autoquest/models/Bill.dart';
import 'package:drivora_autoquest/models/Booking.dart';
import 'package:http/http.dart' as http;
import 'api_connection.dart';

class UserService {
  final ApiService api;

  UserService({required this.api});

  Future<bool> addUserWithFiles({
    required String uid,
    required String email,
    required String contactNumber1,
    required String contactNumber2,
    required File driversLicenseFront,
    required File driversLicenseBack,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/add_userCredentials.php');
      var request = http.MultipartRequest('POST', uri);

      request.fields['uid'] = uid;
      request.fields['email'] = email;
      request.fields['contact_number1'] = contactNumber1;
      request.fields['contact_number2'] = contactNumber2;

      request.files.add(
        await http.MultipartFile.fromPath(
          'drivers_license_front',
          driversLicenseFront.path,
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'drivers_license_back',
          driversLicenseBack.path,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception(jsonResponse['error'] ?? 'Failed to add user');
      }
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  Future<bool> addUserIfNotExists({
    required String uid,
    required String email,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/add_userid_email.php');
      var response = await http.post(uri, body: {'uid': uid, 'email': email});

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception(jsonResponse['error'] ?? 'Failed to add user');
      }
    } catch (e) {
      throw Exception('Error adding user if not exists: $e');
    }
  }

  Future<List<Booking>> getActiveBookings(String uid) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/GetActiveBookingsByUser.php');
      var response = await http.post(uri, body: {'uid': uid});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List) {
          return jsonResponse.map((item) => Booking.fromJson(item)).toList();
        } else if (jsonResponse is Map && jsonResponse.containsKey('error')) {
          throw Exception(jsonResponse['error']);
        } else {
          throw Exception('Unexpected response format: $jsonResponse');
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching active bookings: $e');
    }
  }

  Future<Map<String, dynamic>> getUserById(String uid) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/GetUserById.php?uid=$uid');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          return Map<String, dynamic>.from(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'User not found');
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user by ID: $e');
    }
  }

  Future<bool> updateUserProfile({
    required String uid,
    required String contactNumber1,
    required String contactNumber2,
    File? licenseFront,
    File? licenseBack,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/updateUser.php');
      var request = http.MultipartRequest('POST', uri);

      request.fields['uid'] = uid;
      request.fields['contact_number1'] = contactNumber1;
      request.fields['contact_number2'] = contactNumber2;

      if (licenseFront != null && await licenseFront.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('license_front', licenseFront.path),
        );
      }

      if (licenseBack != null && await licenseBack.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('license_back', licenseBack.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to update user profile',
        );
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  Future<Map<String, dynamic>> getUserBills(String uid) async {
    try {
      var uri = Uri.parse('${apiConnection.baseUrl}/getBills.php');

      var response = await http.post(uri, body: {'uid': uid});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('error')) {
          throw Exception(jsonResponse['error']);
        }

        List<Bill> bills = [];
        if (jsonResponse['bills'] != null && jsonResponse['bills'] is List) {
          bills = (jsonResponse['bills'] as List)
              .map((item) => Bill.fromJson(item))
              .toList();
        }

        double totalAmount = 0.0;
        if (jsonResponse.containsKey('total_amount')) {
          totalAmount =
              double.tryParse(jsonResponse['total_amount'].toString()) ?? 0.0;
        }

        return {'bills': bills, 'total_amount': totalAmount};
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user bills: $e');
    }
  }
}

Future<String> checkUserStatus(String uid) async {
  try {
    final data = await apiConnection.getData('findUser.php?uid=$uid');

    if (data is Map<String, dynamic>) {
      if (data.containsKey('status')) {
        return data['status'] as String;
      } else if (data.containsKey('error')) {
        throw Exception(data['error']);
      }
    }

    throw Exception('Unexpected response format: $data');
  } catch (e) {
    throw Exception('Failed to check user status: $e');
  }
}
