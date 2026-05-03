import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/crash_detection/emergency_protocol_service.dart';

class CrashAlertScreen extends ConsumerStatefulWidget {
  const CrashAlertScreen({super.key});

  @override
  ConsumerState<CrashAlertScreen> createState() => _CrashAlertScreenState();
}

class _CrashAlertScreenState extends ConsumerState<CrashAlertScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isSosTriggered = false;
  bool _isCancelled = false;
  bool _isProtocolFinished = false;
  bool _skipWait = false;
  String _statusText = "Kaza Algılandı!";
  int _countdownSeconds = 10;
  
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  final AudioPlayer _sirenPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _startVibration();
    _startSirenImmediately();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF1A0000),
      end: const Color(0xFF660000),
    ).animate(_animationController);

    _quickStartTts();
    _startPhasedProtocol();
  }

  Future<void> _quickStartTts() async {
    try {
      await _tts.stop();
      _tts.setLanguage("tr-TR");
      await _tts.setSpeechRate(0.6);
      await _tts.setPitch(1.4);
      await _tts.setVolume(1.0);
      
      VolumeController.instance.setVolume(1.0);
      
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (_) {}
  }

  void _startVibration() {
    Vibration.vibrate(
      pattern: [0, 1000, 500, 1000, 500, 1000],
      repeat: 1,
    );
  }

  void _startSirenImmediately() {
    try {
      _sirenPlayer.setReleaseMode(ReleaseMode.loop);
      _sirenPlayer.play(AssetSource('sounds/siren.mp3'), volume: 0.15);
    } catch (_) {}
  }

  Future<void> _initTtsAndAmbiance() async {
    try {
      await _tts.setLanguage("tr-TR");
      await _tts.setSpeechRate(0.6);
      await _tts.setPitch(1.4);
      await _tts.setVolume(1.0);
      VolumeController.instance.showSystemUI = false;
      VolumeController.instance.setVolume(1.0);

      await Future.delayed(const Duration(milliseconds: 500));
      await _tts.speak("İyi misiniz? Kaza yaptığınız tespit edildi. Eğer on saniye içinde iptal etmezseniz acil durum protokolü başlatılacak.");
    } catch (e) {
      debugPrint("TTS ERROR: $e");
    }
  }

  Future<void> _startPhasedProtocol() async {
    final protocol = EmergencyProtocolService(_tts, onStatusUpdate: (s) {
      if (mounted) setState(() => _statusText = s);
    });

    if (await _waitAndCheck(15, "112 İhbarı Hazırlanıyor...")) {
      setState(() => _isSosTriggered = true);
      await protocol.runPhase1("HayatEli Kullanıcısı", () => _isCancelled);

      if (await _waitAndCheck(5, "Yakınlara Haber Veriliyor...", announce: "Yakınlarınıza haber veriliyor.")) {
        await protocol.runPhase2("HayatEli Kullanıcısı", () => _isCancelled);

        if (await _waitAndCheck(10, "Acil Servis Aranıyor...", announce: "Acil servis aranıyor.")) {
          await protocol.runPhase3(() => _isCancelled);
        }
      }
    }
    
    if (!_isCancelled && mounted) {
      setState(() {
        _isProtocolFinished = true;
        _statusText = "PROTOKOL TAMAMLANDI ✓";
        _countdownSeconds = 0;
      });
      try { await _sirenPlayer.stop(); } catch (_) {}
      Vibration.cancel();
    }
  }

  void _triggerEmergency() {
    if (!_isSosTriggered) {
      setState(() {
        _skipWait = true;
        _isSosTriggered = true;
      });
    }
  }

  Future<bool> _waitAndCheck(int seconds, String status, {String? announce}) async {
    if (_isCancelled) return false;
    if (_skipWait) {
      setState(() => _skipWait = false);
      return true;
    }
    
    if (announce != null) {
      _tts.speak(announce).catchError((e) => debugPrint("TTS Error: $e"));
    }
    
    setState(() {
      _statusText = status;
      _countdownSeconds = seconds;
    });

    for (int i = seconds; i >= 0; i--) {
      if (_isCancelled) return false;
      if (_skipWait) {
        setState(() => _skipWait = false);
        return true;
      }
      setState(() => _countdownSeconds = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    return !_isCancelled;
  }

  void _cancelAlert() async {
    _isCancelled = true;
    _timer?.cancel();
    try { await _sirenPlayer.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
    Vibration.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _sirenPlayer.dispose();
    _tts.stop();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: _colorAnimation.value,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Text(
                      _isProtocolFinished ? "Yardım İsteği\nGönderildi" : (_isSosTriggered ? "Acil Durum\nProtokolü Aktif" : "Kaza yaptığınız\ntespit edildi."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSosTriggered ? _statusText : "Yanıt vermezseniz cihazınız\nAcil Durum Protokolü'nü başlatacak.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 40),
                    if (!_isProtocolFinished)
                      Text("$_countdownSeconds", style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w300)),
                    const Spacer(),
                    if (_isProtocolFinished)
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text("EKRANI KAPAT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    else ...[
                      if (!_isSosTriggered)
                        GestureDetector(
                          onTap: _triggerEmergency,
                          child: Container(
                            width: double.infinity, height: 64,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(32)),
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Container(width: 48, height: 48, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle), child: const Center(child: Text("SOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                                const Expanded(child: Text("Hemen Acil Durum Başlat", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
                                const SizedBox(width: 56),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _cancelAlert,
                        child: Column(
                          children: [
                            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 32)),
                            const SizedBox(height: 8),
                            const Text("İptal", style: TextStyle(color: Colors.white54, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
