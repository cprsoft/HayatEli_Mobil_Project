import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final emailServiceProvider = Provider((ref) => EmailService());

class EmailService {
  static final String _serviceId = dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static final String _templateId = dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static final String _publicKey = dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

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
        return true; 
      } else {
        print('EmailJS Hatası: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Email gönderimi sırasında hata: $e');
      return false;
    }
  }
  Future<bool> sendEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final time = DateTime.now().toString().split('.')[0];

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

      return response.statusCode == 200;
    } catch (e) {
      print('EmailJS Hatası: $e');
      return false;
    }
  }
}
