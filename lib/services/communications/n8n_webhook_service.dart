import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_info_plus/device_info_plus.dart';

class N8nWebhookService {
  final String _n8nWebhookUrl = dotenv.get('N8N_WEBHOOK_URL', fallback: 'YOK');
  final String _masterSecret = dotenv.get('MASTER_SECRET', fallback: 'HAYATELI_MASTER_FIX_ME');

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "UNKNOWN_IOS";
    }
    return "UNKNOWN_PLATFORM";
  }

  Future<Map<String, String>> _generateSecurityHeaders() async {
    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final hourString = "${now.year}-${now.month}-${now.day}-${now.hour}";
    final derivedKey = sha256.convert(utf8.encode(_masterSecret + deviceId)).toString();
    final keyBytes = utf8.encode(derivedKey);
    final dataBytes = utf8.encode(hourString);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(dataBytes);
    return {
      'Authorization': 'Bearer ${digest.toString()}',
      'X-Device-ID': deviceId,
    };
  }

  Future<bool> sendSosAlert({
    required String userName,
    required String userPhone,
    required String emergencyContact,
    required String sessionId,
    required String encryptedData,
    required String iv,
    String status = "ACTIVE",
  }) async {
    if (_n8nWebhookUrl == "YOK") return false;
    final headers = await _generateSecurityHeaders();
    try {
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode({
          'sessionId': sessionId,
          'status': status,
          'payload': encryptedData,
          'iv': iv,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
