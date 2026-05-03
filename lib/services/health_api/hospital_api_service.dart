import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HospitalApiService {
  static const String _baseUrl = 'https://www.nosyapi.com/apiv2/service';
  static final String _apiKey = dotenv.env['NOSY_API_KEY'] ?? '';

  Future<List<dynamic>?> getHospitalsByLocation({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/hospital/locations?latitude=$latitude&longitude=$longitude');
    return _sendRequest(url);
  }

  Future<List<dynamic>?> getHospitals({
    required String citySlug,
    String? districtSlug,
  }) async {
    String urlStr = '$_baseUrl/hospital?city=$citySlug';
    if (districtSlug != null && districtSlug.isNotEmpty) {
      urlStr += '&district=$districtSlug';
    }
    final url = Uri.parse(urlStr);
    return _sendRequest(url);
  }

  Future<List<dynamic>?> _sendRequest(Uri url) async {
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          return data['data'] as List<dynamic>;
        } else {
          print("API Hatası: ${data['message']}");
          return null;
        }
      } else {
        print("HTTP Hatası: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('İstek sırasında hata oluştu: $e');
      return null;
    }
  }
}
