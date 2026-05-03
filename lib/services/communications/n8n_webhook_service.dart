import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class N8nWebhookService {
  static const String _n8nWebhookUrl = "http://YOUR_N8N_IP:5678/webhook/sos-alert";
  static const String _secretKey = "HAYATELI_SECRET_12345";

  String _generateHourlyToken() {
    final now = DateTime.now();
    final hourString = "${now.year}-${now.month}-${now.day}-${now.hour}";
    final keyBytes = utf8.encode(_secretKey);
    final dataBytes = utf8.encode(hourString);
    
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);
    
    return digest.toString();
  }

  Future<bool> sendSosAlert({
    required String userName,
    required String userPhone,
    required String emergencyContact,
    required String sessionId,
    required String aesKey,
  }) async {
    final token = _generateHourlyToken();
    final trackingLink = "https://hayateli.com/track/$sessionId#key=$aesKey";

    try {
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userName': userName,
          'userPhone': userPhone,
          'emergencyContact': emergencyContact,
          'trackingLink': trackingLink,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
