import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../services/audio/tts_service.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
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
  bool _isForBystander = false;
  String _statusText = "Kaza Algılandı!";
  int _countdownSeconds = 10;
  String _userName = "HayatEli Kullanıcısı";
  EmergencyProtocolService? _protocolService;
  
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  final AudioPlayer _sirenPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadUserName();
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

  Future<void> _loadUserName() async {
    try {
      final userBox = Hive.box('user_box');
      final jsonStr = userBox.get('cached_user_profile');
      if (jsonStr != null) {
        final data = jsonDecode(jsonStr);
        String name = data['fullName'] ?? 
                     "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        
        if (name.isEmpty || name == "null null") name = "HayatEli Kullanıcısı";

        if (mounted) {
          setState(() => _userName = name);
        }
      }
    } catch (_) {}
  }

  Future<void> _quickStartTts() async {
    try {
      await ref.read(ttsServiceProvider).stop();
      VolumeController.instance.showSystemUI = false;
      VolumeController.instance.setVolume(1.0);
      await ref.read(ttsServiceProvider).speak("İyi misiniz? Kaza yaptığınız tespit edildi. Eğer on saniye içinde iptal etmezseniz acil durum protokolü başlatılacak.");
    } catch (e) {
      debugPrint("TTS ERROR: $e");
    }
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

  Future<void> _startPhasedProtocol() async {
    final protocol = EmergencyProtocolService(ref.read(ttsServiceProvider), onStatusUpdate: (s) {
      if (mounted) setState(() => _statusText = s);
    });

    protocol.startLocationFetch();

    if (await _waitAndCheck(15, "112 İhbarı Hazırlanıyor...")) {
      setState(() => _isSosTriggered = true);
      
      if (!_isForBystander) {
        await protocol.runPhase1(_userName, () => _isCancelled);
        if (await _waitAndCheck(5, "Yakınlara Haber Veriliyor...", announce: "Yakınlarınıza haber veriliyor.")) {
          await protocol.runPhase2(_userName, () => _isCancelled);
        }
      }

      if (await _waitAndCheck(10, "Acil Servis Aranıyor...", announce: "Acil servis aranıyor.")) {
        await protocol.runPhase3(() => _isCancelled);
      }
    }
    
    _protocolService = protocol; // Buton için referansı sakla
    
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

  Future<bool> _waitAndCheck(int seconds, String message, {String? announce}) async {
    if (_isCancelled) return false;
    setState(() {
      _statusText = message;
      _countdownSeconds = seconds;
    });

    for (int i = seconds; i > 0; i--) {
      if (_isCancelled) return false;
      if (_skipWait) break;
      if (announce != null && i == seconds) {
        await ref.read(ttsServiceProvider).speak(announce);
      }
      setState(() {
        _statusText = "$message (${i}s)";
        _countdownSeconds = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() => _countdownSeconds = 0);
    _skipWait = false;
    return true;
  }

  bool _isClosing = false;

  Future<void> _cancelAlert() async {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    
    setState(() {
      _isCancelled = true;
      _statusText = "İptal Edildi";
    });
    try { await ref.read(ttsServiceProvider).stop(); } catch (_) {}
    _sirenPlayer.stop();
    Vibration.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sirenPlayer.dispose();
    _animationController.dispose();
    ref.read(ttsServiceProvider).stop();
    VolumeController.instance.showSystemUI = true;
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
                      _isProtocolFinished ? "Yardım İsteği\n" + (_isForBystander ? "Gönderildi" : "Gönderildi") : (_isSosTriggered ? "Acil Durum\nProtokolü Aktif" : "Kaza yaptığınız\ntespit edildi."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSosTriggered ? _statusText : (_isForBystander ? "Başkası için yardım modu aktif." : "Yanıt vermezseniz cihazınız\nAcil Durum Protokolü'nü başlatacak."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 40),
                    if (!_isProtocolFinished)
                      Text("$_countdownSeconds", style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w300)),
                    const Spacer(),
                    if (_isProtocolFinished)
                      ElevatedButton(
                        onPressed: () async {
                          if (_protocolService != null && _protocolService!.currentSessionId != null) {
                            await _protocolService!.finalizeAndStopTracking(_protocolService!.currentSessionId!);
                          }
                          if (mounted) Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, 
                          foregroundColor: Colors.red, 
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        child: const Text("EKRANI KAPAT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    else ...[
                      if (!_isSosTriggered && !_isForBystander)
                        OutlinedButton(
                          onPressed: () async {
                            setState(() {
                              _isForBystander = true;
                              _skipWait = true; // Beklemeyi atla, direkt protokolü başlat
                              _isSosTriggered = true;
                            });
                            await ref.read(ttsServiceProvider).speak("Başkası için yardım modu aktif. Hemen acil servisi arıyorum.");
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          child: const Text("BAŞKASI İÇİN YARDIM ÇAĞIR"),
                        ),
                      const SizedBox(height: 20),
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
