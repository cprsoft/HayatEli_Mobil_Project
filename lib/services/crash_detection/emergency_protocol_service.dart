import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:send_message/send_message.dart'; // Senin çalışan paket
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../communications/n8n_webhook_service.dart';
import '../audio/tts_service.dart'; // TtsService geri geldi
import 'package:encrypt/encrypt.dart' as enc;
import 'local_contact_service.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:io';

class EmergencyProtocolService {
  final TtsService _tts; // Bizim gelişmiş TTS servisi
  final N8nWebhookService _n8n = N8nWebhookService();
  final Function(String status) onStatusUpdate;
  Timer? _liveTrackingTimer;
  final Battery _battery = Battery();
  bool _isFinalSignalSent = false;

  static const String _targetNumber = "+905052219647";
  Position? _currentPosition;
  Future<Position?>? _locationFuture;

  EmergencyProtocolService(this._tts, {required this.onStatusUpdate});

  void startLocationFetch() {
    _locationFuture = _getLocationSafely();
  }

  Future<Position?> _getLocationSafely() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      ).catchError((_) async => await Geolocator.getLastKnownPosition());
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  Future<void> runPhase1(String userName, bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Acil servis ihbarı hazırlanıyor...");
      
      final userBox = Hive.box('user_box');
      final profileJson = userBox.get('cached_user_profile');
      String finalName = userName;
      if (profileJson != null) {
        final data = jsonDecode(profileJson);
        finalName = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
        if (finalName.isEmpty) finalName = userName;
      }

      await _tts.speak("Kaza algılandı, İyi misiniz? Acil yardım talebi yüzonikiye iletiliyor.");
      
      _currentPosition = await (_locationFuture ?? _getLocationSafely());
      final mapsUrl = _currentPosition != null 
          ? "https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}"
          : "Konum tespit edilemedi.";
      
      final msg = "ACİL DURUM : $finalName kaza geçirmiştir. Tür: Araç Kazası. Konum: $mapsUrl";
      
      // ESKİ ÇALIŞAN SMS YÖNTEMİ
      await _sendSmsToNumber(_targetNumber, msg);
    } catch (_) { 
      onStatusUpdate("Faz 1 tamamlandı..."); 
    }
  }

  Future<void> runPhase2(String userName, bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Yakınlarınıza haber veriliyor...");
      await _tts.speak("Durumunuz yakınlarınıza mesaj olarak gönderiliyor.");
      
      final userBox = Hive.box('user_box');
      final profileJson = userBox.get('cached_user_profile');
      Map<String, dynamic> userData = profileJson != null ? jsonDecode(profileJson) : {};
      final name = "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim();
      final finalName = name.isEmpty ? userName : name;
      final contacts = await LocalContactService.getContacts();
      
      final connectivity = await Connectivity().checkConnectivity();
      final bool hasInternet = !connectivity.contains(ConnectivityResult.none);
      String msg;

      if (hasInternet) {
        final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
        final key = enc.Key.fromSecureRandom(32);
        final iv = enc.IV.fromSecureRandom(16);
        final encrypter = enc.Encrypter(enc.AES(key));
        final batteryLevel = await _battery.batteryLevel;
        
        final payload = jsonEncode({
          'userName': finalName,
          'userPhone': userData['phone'] ?? "Bilinmiyor",
          'emergencyContact': contacts.join(", "),
          'lat': _currentPosition?.latitude,
          'lng': _currentPosition?.longitude,
          'battery': "%$batteryLevel",
          'updateType': 'INITIAL',
        });

        final encrypted = encrypter.encrypt(payload, iv: iv);
        
        await _n8n.sendSosAlert(
          userName: finalName,
          userPhone: userData['phone'] ?? "Bilinmiyor",
          emergencyContact: contacts.join(", "),
          sessionId: sessionId,
          encryptedData: encrypted.base64,
          iv: iv.base64,
          status: "ACTIVE",
        ).timeout(const Duration(seconds: 3), onTimeout: () => false);

        _startLiveTracking(
          userName: finalName,
          userData: userData,
          contacts: contacts,
          sessionId: sessionId,
          key: key,
          iv: iv,
          isCancelled: isCancelled,
        );

        final keyBase64 = key.base64;
        final ivBase64 = iv.base64;
        msg = "ACİL DURUM: Yakınınız $finalName kaza geçirmiştir. CANLI TAKİP: https://hayateli.com/live/$sessionId#key=$keyBase64&iv=$ivBase64";
      } else {
        final mapsUrl = _currentPosition != null 
            ? "https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}"
            : "Konum tespit edilemedi.";
        msg = "ACİL DURUM: Yakınınız $finalName kaza geçirmiştir. SON KONUM: $mapsUrl";
      }

      for (var phone in contacts) {
        if (isCancelled()) return;
        await _sendSmsToNumber(phone, msg);
      }
    } catch (_) { 
      onStatusUpdate("Faz 2 tamamlandı..."); 
    }
  }

  Future<void> runPhase3(bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Acil servis aranıyor...");
      await Future.delayed(const Duration(milliseconds: 500));
      await _tts.speak("Yüzonikiye arama başlatılıyor.");
      await Future.delayed(const Duration(seconds: 2));
      
      // ESKİ ÇALIŞAN OTONOM ARAMA
      await _callEmergency().timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (_) { 
      onStatusUpdate("Faz 3 tamamlandı..."); 
    }
  }

  void _startLiveTracking({
    required String userName,
    required Map<String, dynamic> userData,
    required List<String> contacts,
    required String sessionId,
    required enc.Key key,
    required enc.IV iv,
    required bool Function() isCancelled,
  }) {
    _liveTrackingTimer?.cancel();
    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (isCancelled()) {
        timer.cancel();
        if (!_isFinalSignalSent) {
          _isFinalSignalSent = true;
          _sendFinalStatus(userName, userData, contacts, sessionId, key, iv, "CANCELLED");
        }
        return;
      }
      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) return;

        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        ).catchError((_) => Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low));

        final batteryLevel = await _battery.batteryLevel;
        final encrypter = enc.Encrypter(enc.AES(key));
        final payload = jsonEncode({
          'lat': pos.latitude,
          'lng': pos.longitude,
          'battery': "%$batteryLevel",
          'updateType': 'LIVE_STREAM',
        });
        final encrypted = encrypter.encrypt(payload, iv: iv);
        await _n8n.sendSosAlert(
          userName: userName,
          userPhone: userData['phone'] ?? "Bilinmiyor",
          emergencyContact: contacts.join(", "),
          sessionId: sessionId,
          encryptedData: encrypted.base64,
          iv: iv.base64,
          status: "ACTIVE",
        ).timeout(const Duration(seconds: 3), onTimeout: () => false);
      } catch (_) {}
    });
  }

  Future<void> _sendFinalStatus(String userName, Map<String, dynamic> userData, List<String> contacts, String sessionId, enc.Key key, enc.IV iv, String status) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return;

      final encrypter = enc.Encrypter(enc.AES(key));
      final payload = jsonEncode({
        'message': 'Durum: $status',
        'updateType': 'STATUS_CHANGE',
      });
      final encrypted = encrypter.encrypt(payload, iv: iv);
      await _n8n.sendSosAlert(
        userName: userName,
        userPhone: userData['phone'] ?? "Bilinmiyor",
        emergencyContact: contacts.join(", "),
        sessionId: sessionId,
        encryptedData: encrypted.base64,
        iv: iv.base64,
        status: status,
      ).timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {}
  }

  Future<void> _sendSmsToNumber(String number, String message) async {
    try {
      // SENİN ÇALIŞAN SMS YÖNTEMİN
      await sendSMS(
        message: message,
        recipients: [number],
        sendDirect: true,
      );
    } catch (_) {}
  }

  Future<void> _callEmergency() async {
    try { 
      // SENİN ÇALIŞAN OTONOM ARAMA YÖNTEMİN
      await FlutterPhoneDirectCaller.callNumber(_targetNumber); 
    } catch (_) {}
  }
}
