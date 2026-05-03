import 'package:send_message/send_message.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:another_telephony/telephony.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_contact_service.dart';
import '../communications/n8n_webhook_service.dart';

class EmergencyProtocolService {
  final FlutterTts _tts;
  final Telephony _telephony = Telephony.instance;
  final N8nWebhookService _n8n = N8nWebhookService();
  final Function(String status) onStatusUpdate;

  static const String _targetNumber = "+905052219647";
  Position? _currentPosition;

  EmergencyProtocolService(this._tts, {required this.onStatusUpdate});

  Future<void> _setupVoice(double rate, double pitch) async {
    _tts.setSpeechRate(rate);
    _tts.setPitch(pitch);
  }

  Future<void> runPhase1(String userName, bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Acil servis ihbarı hazırlanıyor...");
      _currentPosition = await _getLocationSafely();
      final mapsUrl = _currentPosition != null 
          ? "https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}"
          : "Konum tespiti başarısız.";
      
      final msg = "ACİL DURUM (HAYATELİ TEST): $userName kaza geçirmiştir. Tür: Araç Kazası. Konum: $mapsUrl Detay: (Yaralı durumu bilinmiyor)";
      
      await _sendSmsToNumber(_targetNumber, msg).timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (_) { onStatusUpdate("Faz 1 tamamlandı..."); }
  }

  Future<void> runPhase2(String userName, bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Yakınlarınıza haber veriliyor...");
      final contacts = await LocalContactService.getContacts();
      
      final mapsUrl = _currentPosition != null 
          ? "https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}"
          : "Konum tespiti başarısız.";

      final connectivity = await Connectivity().checkConnectivity();
      if (!connectivity.contains(ConnectivityResult.none)) {
        await _n8n.sendSosAlert(userName: userName, userPhone: "GÜNCEL", emergencyContact: "YAKINLARI", sessionId: "SOS", aesKey: "KEY")
            .timeout(const Duration(seconds: 3), onTimeout: () => false);
      }

      final msg = "ACİL DURUM (HAYATELİ): Yakınınız $userName kaza geçirmiştir. Konum: $mapsUrl";

      for (var phone in contacts) {
        if (isCancelled()) return;
        await _sendSmsToNumber(phone, msg).timeout(const Duration(seconds: 2), onTimeout: () {});
      }
    } catch (_) { onStatusUpdate("Faz 2 tamamlandı..."); }
  }

  Future<void> runPhase3(bool Function() isCancelled) async {
    if (isCancelled()) return;
    try {
      onStatusUpdate("Acil servis aranıyor...");
      await _callEmergency().timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (_) { onStatusUpdate("Arama başlatıldı..."); }
  }

  Future<void> _sendSmsToNumber(String number, String body) async {
    try {
      await sendSMS(
        message: body,
        recipients: [number],
        sendDirect: true,
      );
    } catch (_) {}
  }

  Future<Position?> _getLocationSafely() async {
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 5));
    } catch (_) { return null; }
  }

  Future<void> _callEmergency() async {
    try { await FlutterPhoneDirectCaller.callNumber(_targetNumber); } catch (_) {}
  }
}
