import 'dart:io';
import 'dart:convert';
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
