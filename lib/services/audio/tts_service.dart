import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isStopped = false;
  bool _isPaused = false;
  String _currentText = "";
  int _lastWordStart = 0;

  TtsService() {
    _tts.setProgressHandler((String text, int start, int end, String word) {
      if (!_isPaused) {
        _currentText = text;
        _lastWordStart = start;
      }
    });
    _tts.setErrorHandler((_) {});
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (Platform.isAndroid) {
        await _tts.setEngine("com.google.android.tts");
        await _tts.awaitSpeakCompletion(true);
      }
      await _tts.setLanguage("tr-TR");
      await _tts.setSpeechRate(0.6);
      await _tts.setPitch(1.4);
      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    await initialize();
    _isStopped = false;
    try {
      if (_isPaused &&
          _currentText == text &&
          _lastWordStart > 0 &&
          _lastWordStart < text.length) {
        final remaining = text.substring(_lastWordStart);
        _isPaused = false;
        _currentText = text;
        await _tts.speak(remaining);
      } else {
        _isPaused = false;
        _currentText = text;
        _lastWordStart = 0;
        await _tts.speak(text);
      }
    } catch (_) {}
  }

  Future<void> pause() async {
    _isPaused = true;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> stop() async {
    _isStopped = true;
    _isPaused = false;
    _currentText = "";
    _lastWordStart = 0;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  bool get isStopped => _isStopped;
  bool get isPaused => _isPaused;
}
