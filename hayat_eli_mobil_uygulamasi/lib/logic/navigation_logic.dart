import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../screens/route_map_screen.dart';
import '../services/cloud_tts_service.dart';
import '../services/route_service.dart';

/// Navigasyon ekranının ağır mantık (GPS, Rota, Uyarılar) kısmını yöneten mixin.
mixin NavigationLogic on State<RouteMapScreen> {
  // ─── Durum Değişkenleri ───
  bool isLoading = true;
  String distanceText = '';
  String durationText = '';
  List<dynamic> steps = [];
  List<LatLng> routePoints = [];
  bool isNavigating = false;
  int currentStepIndex = 0;
  String currentInstruction = '';
  String currentStepDistance = '';
  bool hasArrived = false;
  String remainingDistanceText = '';
  bool isRecalculating = false;
  DateTime? lastRecalcTime;

  // EMA Filtre (Hassas Takip)
  double? smoothLat;
  double? smoothLng;
  double? smoothBearing;
  final double alpha = 0.12;
  final double speedThresholdMs = 0.5;

  // TTS & GPS Kontrol
  bool navGPSReady = false;
  int lastSpokenStep = -1;
  final Set<String> spokenWarnings = {};
  StreamSubscription<Position>? navigationStream;

  // ─── Temizleme Yardımcısı ───
  String removeHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
  }

  /// Mesafe Hesaplama (Haversine)
  double calcDistance(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final s = sin(dLat / 2) * sin(dLat / 2) +
        cos(a.latitude * pi / 180) * cos(b.latitude * pi / 180) *
            sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(s), sqrt(1 - s));
  }

  /// Rota Verisini Uygula
  void applyRouteData(Map<String, dynamic> routeData, int selectedIndex, List<Map<String, dynamic>> alternatives, Set<Polyline> polylines, String travelMode) {
    final List<LatLng> pts = List<LatLng>.from(routeData['polyline']);
    distanceText = routeData['distance'];
    durationText = routeData['duration'];
    steps = routeData['steps'] ?? [];
    routePoints = pts;
    remainingDistanceText = distanceText;

    if (steps.isNotEmpty) {
      currentInstruction = removeHtml(steps[0]['html_instructions'] ?? '');
      currentStepDistance = steps[0]['distance']?['text'] ?? '';
    }

    polylines.clear();
    // Alternatifler (Gri)
    for (int i = 0; i < alternatives.length; i++) {
      if (i == selectedIndex) continue;
      polylines.add(Polyline(
        polylineId: PolylineId('alt_$i'),
        points: List<LatLng>.from(alternatives[i]['polyline']),
        color: Colors.grey.withOpacity(0.45),
        width: 5,
      ));
    }

    // Ana Rota
    final isWalking = travelMode == 'walking';
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: pts,
      color: const Color(0xFF1A73E8),
      width: isWalking ? 6 : 8,
      patterns: isWalking ? [PatternItem.dot, PatternItem.gap(12)] : [],
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    ));
  }

  /// Kamerayı Sığdır
  void fitBounds(GoogleMapController? controller, LatLng a, LatLng b) {
    if (controller == null) return;
    double minLat = min(a.latitude, b.latitude);
    double maxLat = max(a.latitude, b.latitude);
    double minLng = min(a.longitude, b.longitude);
    double maxLng = max(a.longitude, b.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  /// Durdurma
  void stopNavigationLogic(AudioPlayer player, VoidCallback onRefresh) {
    navigationStream?.cancel();
    player.stop();
    WakelockPlus.disable();
    isNavigating = false;
    hasArrived = false;
    smoothLat = null;
    smoothLng = null;
    smoothBearing = null;
    lastSpokenStep = -1;
    spokenWarnings.clear();
    onRefresh();
  }
}
