import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<Position>? _positionStream;
  String? currentSessionId;
  Position? _lastPosition;

  encrypt.Key? _aesKey;
  encrypt.IV? _iv;

  String _generateSecureSessionId() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return encrypt.Key(Uint8List.fromList(values)).base64.replaceAll(RegExp(r'[=/+]'), '');
  }

  String _encryptData(String plainText) {
    if (_aesKey == null || _iv == null) return plainText;
    final encrypter = encrypt.Encrypter(encrypt.AES(_aesKey!, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: _iv!);
    return encrypted.base64;
  }

  Future<Map<String, String>> startTracking({required String userId, required String userName}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Lütfen Konum servisini açın.");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception("Konum izni reddedildi.");
    }

    currentSessionId = _generateSecureSessionId();

    _aesKey = encrypt.Key.fromSecureRandom(32);
    _iv = encrypt.IV.fromSecureRandom(16);

    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        forceLocationManager: true,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "HayatEli mevcut konumunuzu paylaşıyor",
          notificationTitle: "Canlı Takip Aktif",
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, 
        distanceFilter: 5
      );
    }

    Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    if (initialPosition.isMocked) throw Exception("Sahte konum (Mock Location) tespit edildi.");
    _lastPosition = initialPosition;

    final String locationJson = jsonEncode({
      'lat': initialPosition.latitude,
      'lng': initialPosition.longitude,
      'spd': initialPosition.speed
    });
    
    final String encryptedLocation = _encryptData(locationJson);

    await _firestore.collection('LiveTrackingSessions').doc(currentSessionId).set({
      'userId': userId,
      'userName': userName, 
      'encryptedData': encryptedLocation,
      'iv': _iv!.base64,
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (position.isMocked) return;

      if (_lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude, 
          position.latitude, position.longitude
        );
        if (distance < 5) return;
      }
      _lastPosition = position;
      
      final String streamJson = jsonEncode({
        'lat': position.latitude, 
        'lng': position.longitude, 
        'spd': position.speed
      });
      
      _firestore.collection('LiveTrackingSessions').doc(currentSessionId).update({
        'encryptedData': _encryptData(streamJson),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return {
      'sessionId': currentSessionId!,
      'aesKey': _aesKey!.base64 
    };
  }

  Future<void> stopTracking() async {
    if (_positionStream != null) {
      await _positionStream!.cancel();
      _positionStream = null;
    }
    if (currentSessionId != null) {
      await _firestore.collection('LiveTrackingSessions').doc(currentSessionId).delete();
      currentSessionId = null;
    }
  }
}
