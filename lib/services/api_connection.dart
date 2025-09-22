import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<dynamic>> getData(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }

  Future<Map<String, dynamic>> postData(
    String endpoint,
    Map<String, String> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to post data to $endpoint: ${response.statusCode}',
      );
    }
  }
}

final ApiService apiConnection = ApiService(
  baseUrl: 'http://10.199.254.222/drivora_api',
);
