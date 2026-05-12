import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  Future<void>? _initFuture;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInitialization();
    return _initFuture;
  }

  Future<void> _doInitialization() async {
    try {
      if (Platform.isAndroid) {
        await _tts.setEngine("com.google.android.tts");
      }
      await _tts.setLanguage("tr-TR");
      await _tts.setSpeechRate(0.6);
      await _tts.setPitch(1.4);
      _isInitialized = true;
    } catch (_) {
      _initFuture = null;
    }
  }

  Future<void> init() async {
    try {
      if (Platform.isAndroid) {
        await _tts.setEngine("com.google.android.tts");
      }
      await _tts.setLanguage("tr-TR");
      await _tts.setSpeechRate(0.6);
      await _tts.setPitch(1.4);
      await _tts.setVolume(0.0);
      await _tts.speak(" "); // Sessizce motoru ateşle
      await _tts.setVolume(1.0);
      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();
    try {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
