import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudTtsService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_KEY'] ?? '';
  static const String _apiUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  static const List<Map<String, dynamic>> femaleVoices = [
    {
      'id': 'tr-TR-Neural2-C',
      'name': 'Zuhal (Yapay Zeka)',
      'quality': 'Neural2',
      'description': 'En doğal, premium kadın sesi',
      'languageCode': 'tr-TR',
      'isDefault': true,
    },
    {
      'id': 'tr-TR-Neural2-A',
      'name': 'Aoede (Yapay Zeka)',
      'quality': 'Neural2',
      'description': 'Yumuşak, profesyonel kadın sesi',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Wavenet-C',
      'name': 'Sulafat (WaveNet)',
      'quality': 'WaveNet',
      'description': 'Enerjik kadın sesi',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Wavenet-E',
      'name': 'WaveNet E',
      'quality': 'WaveNet',
      'description': 'Doğal kadın sesi (WaveNet)',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Wavenet-A',
      'name': 'WaveNet A',
      'quality': 'WaveNet',
      'description': 'Klasik kadın sesi (WaveNet)',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
  ];

  static const List<Map<String, dynamic>> maleVoices = [
    {
      'id': 'tr-TR-Neural2-B',
      'name': 'Fenrir (Yapay Zeka)',
      'quality': 'Neural2',
      'description': 'Güçlü, premium erkek sesi',
      'languageCode': 'tr-TR',
      'isDefault': true,
    },
    {
      'id': 'tr-TR-Neural2-E',
      'name': 'Charon (Yapay Zeka)',
      'quality': 'Neural2',
      'description': 'Derin, otoriter erkek sesi',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Wavenet-B',
      'name': 'WaveNet B',
      'quality': 'WaveNet',
      'description': 'Doğal erkek sesi (WaveNet)',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
  ];

  static const String defaultFemaleVoiceId = 'tr-TR-Neural2-C';
  static const String defaultMaleVoiceId = 'tr-TR-Neural2-B';

  static Map<String, dynamic>? getVoiceById(String id) {
    final all = [...femaleVoices, ...maleVoices];
    try {
      return all.firstWhere((v) => v['id'] == id);
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> synthesize(
    String text, {
    String voiceId = defaultFemaleVoiceId,
    double speakingRate = 1.05,
  }) async {
    if (text.isEmpty) return null;

    final voiceInfo = getVoiceById(voiceId);
    final languageCode = voiceInfo?['languageCode'] ?? 'tr-TR';

    try {
      final response = await http
          .post(
            Uri.parse('$_apiUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'input': {'text': text},
              'voice': {
                'languageCode': languageCode,
                'name': voiceId,
              },
              'audioConfig': {
                'audioEncoding': 'MP3',
                'speakingRate': speakingRate,
                'pitch': 0.0,
              },
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final audioContent = body['audioContent'] as String?;
        if (audioContent != null) {
          return base64Decode(audioContent);
        }
      } else {
        debugPrint('[CloudTTS] HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[CloudTTS] Error/Timeout: $e');
    }
    return null;
  }
}
