import 'dart:convert';
import 'package:http/http.dart' as http;

class NobetciEczaneApi {
  static const String _baseUrl = 'https://www.nosyapi.com/apiv2/service';
  static const String _apiKey = 'TOyOFiAfMAACNk4famWOWPTHVCkniCqIAEic0gHuR51k5FbMGhokjM1sbWXJ';

  /// Cihazın lokasyonuna (latitude ve longitude) göre en yakın 20 nöbetçi eczaneyi getirir.
  Future<List<dynamic>?> getPharmaciesByLocation({
    required double latitude,
    required double longitude,
  }) async {
    // 2. resim ve 1. resimden yola çıkarak tespit edilen uç nokta
    final url = Uri.parse('$_baseUrl/pharmacies-on-duty/locations?latitude=$latitude&longitude=$longitude');
    return _sendRequest(url);
  }

  /// İl ve (opsiyonel) ilçe değerine göre NÖBETÇİ ECZANELERİ getirir.
  Future<List<dynamic>?> getPharmacies({
    required String citySlug,
    String? districtSlug,
  }) async {
    String urlStr = '$_baseUrl/pharmacies-on-duty?city=$citySlug';
    if (districtSlug != null && districtSlug.isNotEmpty) {
      // 2. resimde görüldüğü üzere parametre adı 'district'
      urlStr += '&district=$districtSlug'; 
    }
    final url = Uri.parse(urlStr);
    return _sendRequest(url);
  }

  /// İl ve ilçelere ait nöbetçi eczanelerin istatistiğini/sayısını (`dutyPharmacyCount`) döndürür.
  /// İsteğe bağlı olarak sadece bir şehre ait (örn: ankara) veriler çekilebilir.
  Future<List<dynamic>?> getPharmacyCount({String? citySlug}) async {
    String urlStr = '$_baseUrl/pharmacies-on-duty/count-cities';
    if (citySlug != null && citySlug.isNotEmpty) {
      urlStr += '?city=$citySlug';
    }
    final url = Uri.parse(urlStr);
    return _sendRequest(url);
  }

  /// Türkiye ve Kıbrıs'taki TÜM nöbetçi eczaneleri tek seferde çeker.
  /// (DİKKAT: Bu sorgu her başarılı istekte 81 kredi, yani il sayısı kadar kredi tüketir.)
  Future<List<dynamic>?> getAllPharmacies() async {
    final url = Uri.parse('$_baseUrl/pharmacies-on-duty/all');
    return _sendRequest(url);
  }

  /// Nöbetçi eczanelerin veritabanında en son ne zaman güncellendiği bilgisini döndürür (0 Kredi).
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
          // map_screen.dart arayüzü hastane verisine alıştığı için 'name' bekliyor.
          // 3. resimden gördüğümüz üzere eczane adı 'pharmacyName' olarak geliyor.
          // Bu yüzden haritaya aktarmadan önce 'pharmacyName' -> 'name' formatına çeviriyoruz.
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
