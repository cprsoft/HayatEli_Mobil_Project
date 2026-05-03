import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CrashDetectionService {
  static final CrashDetectionService _instance = CrashDetectionService._internal();
  factory CrashDetectionService() => _instance;
  CrashDetectionService._internal();

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<BarometerEvent>? _pressureSub;

  final int _maxBufferSize = 60;
  final List<UserAccelerometerEvent> _accelBuffer = [];
  final List<GyroscopeEvent> _gyroBuffer = [];
  final List<BarometerEvent> _pressureBuffer = [];

  final double _crashThreshold = 39.2;
  bool _isServiceRunning = false;

  void startListening() {
    if (_isServiceRunning) return;
    _isServiceRunning = true;

    _accelSub = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (UserAccelerometerEvent event) {
        _addToBuffer(_accelBuffer, event);
        _checkForCrash(event);
      },
      onError: (error) {
        debugPrint("Error: $error");
      },
      cancelOnError: false,
    );

    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (GyroscopeEvent event) {
        _addToBuffer(_gyroBuffer, event);
      },
      onError: (error) {
        debugPrint("Error: $error");
      },
      cancelOnError: false,
    );

    _pressureSub = barometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (BarometerEvent event) {
        _addToBuffer(_pressureBuffer, event);
      },
      onError: (error) {
        debugPrint("Barometre hatası veya cihazda yok: $error");
      },
      cancelOnError: false,
    );
  }

  void stopListening() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _pressureSub?.cancel();
    
    _accelBuffer.clear();
    _gyroBuffer.clear();
    _pressureBuffer.clear();
    
    _isServiceRunning = false;
  }

  void _addToBuffer<T>(List<T> buffer, T event) {
    if (buffer.length >= _maxBufferSize) {
      buffer.removeAt(0);
    }
    buffer.add(event);
  }

  void _checkForCrash(UserAccelerometerEvent event) {
    double magnitude = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

    if (magnitude > _crashThreshold) {
      debugPrint("CRASH: ${magnitude.toStringAsFixed(2)}");
    }
  }
}
