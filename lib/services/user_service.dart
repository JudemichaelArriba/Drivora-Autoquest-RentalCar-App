import 'dart:io';
import 'dart:convert';
import 'package:drivora_autoquest/models/Bill.dart';
import 'package:drivora_autoquest/models/Booking.dart';
import 'package:drivora_autoquest/models/user.dart';
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

  Future<User> getUserById(String uid) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/GetUserById.php?uid=$uid');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          return User.fromJson(Map<String, dynamic>.from(jsonResponse['data']));
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
    String? firstName,
    String? lastName,
    File? licenseFront,
    File? licenseBack,
    File? profilePic,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/updateUser.php');
      var request = http.MultipartRequest('POST', uri);

      request.fields['uid'] = uid;
      request.fields['contact_number1'] = contactNumber1;
      request.fields['contact_number2'] = contactNumber2;

      if (firstName != null) request.fields['first_name'] = firstName;
      if (lastName != null) request.fields['last_name'] = lastName;

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

      if (profilePic != null && await profilePic.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_pic', profilePic.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception(
          jsonResponse['error'] ?? 'Failed to update user profile',
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

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/loginUser.php');
      var response = await http.post(
        uri,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          return {
            'status': 'success',
            'message': jsonResponse['message'] ?? 'Login successful',
          };
        } else {
          return {
            'status': 'error',
            'message': jsonResponse['message'] ?? 'Invalid credentials',
          };
        }
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<bool> signupUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/signUp.php');
      var response = await http.post(
        uri,
        body: {
          'uid': uid,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        return true;
      } else {
        throw Exception(jsonResponse['error'] ?? 'Failed to sign up user');
      }
    } catch (e) {
      throw Exception('Error signing up user: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(String uid) async {
    try {
      var uri = Uri.parse('${api.baseUrl}/GetUserById.php');
      var response = await http.post(uri, body: {'uid': uid});

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('error')) {
          throw Exception(jsonResponse['error']);
        }

        if (jsonResponse['drivers_license_front'] != null) {
          jsonResponse['drivers_license_front'] = base64Decode(
            jsonResponse['drivers_license_front'],
          );
        }
        if (jsonResponse['drivers_license_back'] != null) {
          jsonResponse['drivers_license_back'] = base64Decode(
            jsonResponse['drivers_license_back'],
          );
        }
        if (jsonResponse['profile_pic'] != null) {
          jsonResponse['profile_pic'] = base64Decode(
            jsonResponse['profile_pic'],
          );
        }

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user details: $e');
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
