import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Google Cloud Text-to-Speech API servisi.
/// Türkçe WaveNet ve Chirp3-HD sesleri kullanır.
class CloudTtsService {
  static const String _apiKey = 'AIzaSyA0S2aZt3PcdG5KVDRx_gCmGsw2cPx4wfs';
  static const String _apiUrl =
      'https://texttospeech.googleapis.com/v1/text:synthesize';

  /// ─── Mevcut Türkçe Sesler ───────────────────────────────────────────────
  /// Chirp3-HD: En doğal, insan sesine en yakın (ücretli tier)
  /// WaveNet:   Doğal, sinir ağı bazlı (ücretsiz kota daha geniş)
  /// Standard:  Temel TTS (en robot)
  static const List<Map<String, dynamic>> femaleVoices = [
    {
      'id': 'tr-TR-Chirp3-HD-Zuhal',
      'name': 'Zuhal',
      'quality': 'Chirp3 HD',
      'description': 'En doğal, samimi kadın sesi ⭐',
      'languageCode': 'tr-TR',
      'isDefault': true,
    },
    {
      'id': 'tr-TR-Chirp3-HD-Aoede',
      'name': 'Aoede',
      'quality': 'Chirp3 HD',
      'description': 'Yumuşak, profesyonel kadın sesi',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Chirp3-HD-Sulafat',
      'name': 'Sulafat',
      'quality': 'Chirp3 HD',
      'description': 'Enerjik, genç kadın sesi',
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
      'id': 'tr-TR-Chirp3-HD-Fenrir',
      'name': 'Fenrir',
      'quality': 'Chirp3 HD',
      'description': 'Güçlü, doğal erkek sesi ⭐',
      'languageCode': 'tr-TR',
      'isDefault': true,
    },
    {
      'id': 'tr-TR-Chirp3-HD-Charon',
      'name': 'Charon',
      'quality': 'Chirp3 HD',
      'description': 'Derin, otoriter erkek sesi',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
    {
      'id': 'tr-TR-Chirp3-HD-Puck',
      'name': 'Puck',
      'quality': 'Chirp3 HD',
      'description': 'Enerjik, dinamik erkek sesi',
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
    {
      'id': 'tr-TR-Wavenet-C',
      'name': 'WaveNet C',
      'quality': 'WaveNet',
      'description': 'Klasik erkek sesi (WaveNet)',
      'languageCode': 'tr-TR',
      'isDefault': false,
    },
  ];

  static const String defaultFemaleVoiceId = 'tr-TR-Chirp3-HD-Zuhal';
  static const String defaultMaleVoiceId = 'tr-TR-Chirp3-HD-Fenrir';

  /// VoiceId'e göre ses bilgisini döner
  static Map<String, dynamic>? getVoiceById(String id) {
    final all = [...femaleVoices, ...maleVoices];
    try {
      return all.firstWhere((v) => v['id'] == id);
    } catch (_) {
      return null;
    }
  }

  /// Metni sese çevirir, MP3 bytes döner (null → hata)
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
          .timeout(const Duration(seconds: 8)); // 8 saniye ideal bir sınır

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final audioContent = body['audioContent'] as String?;
        if (audioContent != null) {
          return base64Decode(audioContent);
        }
      } else {
        debugPrint('[CloudTTS] HTTP ${response.statusCode}: ${response.body}');
        // Chirp3-HD desteklenmiyorsa WaveNet'e düş
        if (response.statusCode == 400 && voiceId.contains('Chirp3')) {
          final fallbackId = voiceId.contains('Fenrir') ||
                  voiceId.contains('Charon') ||
                  voiceId.contains('Puck')
              ? defaultMaleVoiceId.replaceFirst('Chirp3-HD-Fenrir', 'Wavenet-B')
              : defaultFemaleVoiceId.replaceFirst('Chirp3-HD-Zuhal', 'Wavenet-E');
          debugPrint('[CloudTTS] Chirp3-HD desteklenmiyor, WaveNet\'e geçiliyor: $fallbackId');
          return synthesize(text, voiceId: fallbackId, speakingRate: speakingRate);
        }
      }
    } catch (e) {
      debugPrint('[CloudTTS] Error/Timeout: $e');
      // Timeout veya başka bir hatada hemen WaveNet'e düş (Sessiz kalma!)
      if (voiceId.contains('Chirp3')) {
        final fallbackId = voiceId.contains('Fenrir') || voiceId.contains('Charon') || voiceId.contains('Puck')
            ? 'tr-TR-Wavenet-B'
            : 'tr-TR-Wavenet-E';
        debugPrint('[CloudTTS] Hata sonrası WaveNet fallback: $fallbackId');
        return synthesize(text, voiceId: fallbackId, speakingRate: speakingRate);
      }
    }
    return null;
  }
}
