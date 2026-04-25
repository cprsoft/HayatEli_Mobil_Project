import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NobetciEczaneApi {
  static const String _baseUrl = 'https://www.nosyapi.com/apiv2/service';
  static final String _apiKey = dotenv.env['NOSY_API_KEY'] ?? '';

  Future<List<dynamic>?> getPharmaciesByLocation({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl/pharmacies-on-duty/locations?latitude=$latitude&longitude=$longitude');
    return _sendRequest(url);
  }

  Future<List<dynamic>?> getPharmacies({
    required String citySlug,
    String? districtSlug,
  }) async {
    String urlStr = '$_baseUrl/pharmacies-on-duty?city=$citySlug';
    if (districtSlug != null && districtSlug.isNotEmpty) {
      urlStr += '&district=$districtSlug'; 
    }
    final url = Uri.parse(urlStr);
    return _sendRequest(url);
  }

  Future<List<dynamic>?> getPharmacyCount({String? citySlug}) async {
    String urlStr = '$_baseUrl/pharmacies-on-duty/count-cities';
    if (citySlug != null && citySlug.isNotEmpty) {
      urlStr += '?city=$citySlug';
    }
    final url = Uri.parse(urlStr);
    return _sendRequest(url);
  }

  Future<List<dynamic>?> getAllPharmacies() async {
    final url = Uri.parse('$_baseUrl/pharmacies-on-duty/all');
    return _sendRequest(url);
  }

  Future<String?> getPharmacyStatus() async {
    final url = Uri.parse('$_baseUrl/pharmacies-on-duty/status');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data']['lastupdated']?.toString();
        }
      }
    } catch (e) {
      print('Status isteği sırasında hata: $e');
    }
    return null;
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
          final List<dynamic> rawData = data['data'] as List<dynamic>;
          return rawData.map((item) {
            if (item['pharmacyName'] != null) {
              item['name'] = item['pharmacyName'];
            }
            return item;
          }).toList();
        } else {
          print("Nöbetçi Eczane API Hatası: ${data['message']}");
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
