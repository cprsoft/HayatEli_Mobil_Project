import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EmailJS servisine erişim için provider
final emailServiceProvider = Provider((ref) => EmailService());

class EmailService {
  // ─── EMAILJS AYARLARI ───
  // Kral, bu bilgileri EmailJS panelinden aldığında buraya yapıştır:
  static const String _serviceId = 'service_ndydpwk';
  static const String _templateId = 'template_gfgzmod';
  static const String _publicKey = 'SoBBPoQB1VVY6DpvQ';

  /// Giriş yapmak isteyen kullanıcıya 6 haneli OTP kodu gönderir.
  Future<bool> sendLoginOtp({
    required String email,
    required String otpCode,
    required String time,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'user_email': email,
            'otp_code': otpCode,
            'time': time,
            'app_name': 'HAYATELİ',
          },
        }),
      );

      if (response.statusCode == 200) {
        return true; // Başarılı
      } else {
        print('EmailJS Hatası: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Email gönderimi sırasında hata: $e');
      return false;
    }
  }
}
