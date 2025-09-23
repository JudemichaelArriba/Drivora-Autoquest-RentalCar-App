import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Future<List<dynamic>> getData(String endpoint) async {
  //   final url = Uri.parse('$baseUrl/$endpoint');
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to load data from $endpoint');
  //   }
  // }

  Future<dynamic> getData(String endpoint) async {
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

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, File> files,
  ) async {
    var uri = Uri.parse('$baseUrl/$endpoint');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    for (var entry in files.entries) {
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value.path),
      );
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }
}

final ApiService apiConnection = ApiService(
  baseUrl: 'http://10.199.254.222/drivora_api',
);
