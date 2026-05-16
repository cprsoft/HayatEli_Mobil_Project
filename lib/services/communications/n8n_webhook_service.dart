import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class N8nWebhookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> sendSosAlert({
    required String userName,
    required String userPhone,
    required String emergencyContact,
    required String sessionId,
    required String encryptedData,
    required String iv,
    String status = "ACTIVE",
  }) async {
    try {
      debugPrint("🔥 FIREBASE CANLI TAKİP: $sessionId");
      
      // Veriyi direkt hedefe, Firebase'e yazıyoruz. 
      // N8N'deki "Delete/Create" karmaşası burada SetOptions(merge: true) ile çözülüyor.
      await _firestore.collection('active_sos').doc(sessionId).set({
        'sessionId': sessionId,
        'status': status,
        'payload': encryptedData,
        'iv': iv,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'lastUpdate': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
        'userName': userName,
        'userPhone': userPhone,
        'emergencyContact': emergencyContact,
      }, SetOptions(merge: true));

      debugPrint("✅ FIREBASE BAŞARILI: Veri saniyeler içinde hedefe ulaştı!");
      return true;
    } catch (e) {
      debugPrint("❌ FIREBASE HATASI: $e");
      // Hata olsa bile sistemi durdurmuyoruz, bir sonraki paketi bekliyoruz.
      return false;
    }
  }
}
