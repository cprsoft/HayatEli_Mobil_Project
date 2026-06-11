import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class HayatAiService {
  bool _isInitialized = false;

  String? _userName;
  String? _bloodType;
  List<String> _allergies = [];
  List<String> _chronicDiseases = [];
  List<String> _medications = [];

  static const String _apiBaseUrl = "http://127.0.0.1:8000";

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _loadUserProfileOnce();
      _isInitialized = true;
    } catch (e) {
      print("Hayat AI Başlatma Hatası: $e");
    }
  }

  Future<void> _loadUserProfileOnce() async {
    try {
      final userBox = Hive.box('user_box');
      final profileJson = userBox.get('cached_user_profile');
      if (profileJson != null) {
        final userData = jsonDecode(profileJson);
        _userName = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
        _bloodType = userData['bloodType'];
        _allergies = _parseToList(userData['allergies']);
        _chronicDiseases = _parseToList(userData['chronicDiseases']);
        _medications = _parseToList(userData['currentMedications']);
        print("Hayat AI: $_userName kullanıcısı başarıyla hafızaya alındı.");
      }
    } catch (e) {
      print("Hafıza yüklenirken hata oluştu: $e");
    }
  }

  List<String> _parseToList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString().trim()).toList();
    if (value is String) {
      return value.split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [value.toString()];
  }

  Future<Map<String, dynamic>> analyzeAndRespond(String userInput) async {
    if (!_isInitialized) await initialize();

    try {
      final url = Uri.parse("$_apiBaseUrl/chat");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({
          "message": userInput,
          "name": _userName,
          "blood_type": _bloodType,
          "allergies": _allergies,
          "chronic_diseases": _chronicDiseases,
          "medications": _medications,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          "response": data['response']?.toString().trim() ?? "",
          "dynamic_buttons": List<String>.from(data['dynamic_buttons'] ?? [])
        };
      }
    } catch (e) {
      print("FastAPI Bağlantı Hatası: $e");
    }

    return {"response": "Yapay zeka servisi şu an çevrimdışı.", "dynamic_buttons": []};
  }
}
