import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../services/cloud_tts_service.dart';
import '../services/route_service.dart';
import '../logic/navigation_logic.dart';
import '../widgets/nav_controls.dart';
import '../widgets/nav_bottom_sheets.dart';

class RouteMapScreen extends StatefulWidget {
  final String targetName;
  final double targetLat;
  final double targetLng;

  const RouteMapScreen({
    super.key,
    required this.targetName,
    required this.targetLat,
    required this.targetLng,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> with NavigationLogic {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  MapType _currentMapType = MapType.normal;
  bool _isTrafficEnabled = false;
  String _travelMode = 'driving';

  // Cloud TTS + Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isTtsEnabled = true;
  String _selectedVoiceGender = 'female';
  String _selectedVoiceId = CloudTtsService.defaultFemaleVoiceId;
  bool _isSpeaking = false;

  // Alternatif Rotalar State
  List<Map<String, dynamic>> _alternativeRoutes = [];
  int _selectedRouteIndex = 0;

  // İkonlar
  BitmapDescriptor? _carMarkerIcon;
  BitmapDescriptor? _walkMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createCustomMarkers();
    _initRoute();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    navigationStream?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // ─── Yardımcılar ───

  Future<void> _createCustomMarkers() async {
    _carMarkerIcon = await _drawNavArrow(const Color(0xFF1A73E8), Icons.navigation_rounded, 64);
    _walkMarkerIcon = await _drawNavArrow(Colors.teal, Icons.directions_walk_rounded, 64);
  }

  Future<BitmapDescriptor> _drawNavArrow(Color color, IconData iconData, int size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final double s = size.toDouble();
    final shadowPaint = Paint()..color = color.withOpacity(0.25);
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, shadowPaint);
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2 - 6, circlePaint);
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2 - 6, borderPaint);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(fontSize: s * 0.45, fontFamily: iconData.fontFamily, package: iconData.fontPackage, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(s / 2 - textPainter.width / 2, s / 2 - textPainter.height / 2));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  // ─── Aksiyonlar ───

  Future<void> _initRoute() async {
    setState(() {
      isLoading = true;
      _polylines.clear();
      _markers.clear();
      isNavigating = false;
      hasArrived = false;
      currentStepIndex = 0;
      currentInstruction = '';
      _alternativeRoutes = [];
    });

    try {
      Position? best;
      try {
        best = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation, timeLimit: const Duration(seconds: 10));
      } catch (_) {
        best = await Geolocator.getLastKnownPosition();
      }

      if (best == null) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum şu an alınamıyor.')));
        }
        return;
      }

      final origin = LatLng(best.latitude, best.longitude);
      final dest = LatLng(widget.targetLat, widget.targetLng);

      _markers.add(Marker(markerId: const MarkerId('destination'), position: dest, infoWindow: InfoWindow(title: widget.targetName)));

      final routes = await RouteService().getAlternativeRoutes(origin, dest, mode: _travelMode);
      if (routes.isNotEmpty && mounted) {
        setState(() {
          _alternativeRoutes = routes;
          _selectedRouteIndex = 0;
          applyRouteData(routes[0], 0, _alternativeRoutes, _polylines, _travelMode);
        });
        await Future.delayed(const Duration(milliseconds: 500));
        fitBounds(_mapController, origin, dest);
      }
    } catch (e) {
      debugPrint('Route Init Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _startLocalNavigation() {
    if (steps.isEmpty) return;
    WakelockPlus.enable();
    final first = steps.isNotEmpty ? removeHtml(steps[0]['html_instructions'] ?? '') : '';

    setState(() {
      isNavigating = true;
      _isTrafficEnabled = true;
      currentStepIndex = 0;
      hasArrived = false;
      lastSpokenStep = 0;
      spokenWarnings.clear();
      navGPSReady = false;
      smoothLat = null; smoothLng = null;
      currentInstruction = first;
      currentStepDistance = steps.isNotEmpty ? (steps[0]['distance']?['text'] ?? '') : '';
    });

    Geolocator.getLastKnownPosition().then((pos) {
      if (pos != null && mounted) {
        _updateNavMarker(LatLng(pos.latitude, pos.longitude), pos.heading);
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 19, tilt: 65, bearing: pos.heading)));
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && isNavigating) {
        _speak('HayatEli rotanızı oluşturuyor. $first');
      }
    });

    navigationStream = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 8)).listen((pos) {
      if (!mounted) return;
      
      // EMA logic
      smoothLat = smoothLat == null ? pos.latitude : smoothLat! * (1 - alpha) + pos.latitude * alpha;
      smoothLng = smoothLng == null ? pos.longitude : smoothLng! * (1 - alpha) + pos.longitude * alpha;
      if (pos.speed >= speedThresholdMs) {
        smoothBearing = smoothBearing == null ? pos.heading : smoothBearing! * (1 - alpha) + pos.heading * alpha;
      }

      if (!navGPSReady) {
        navGPSReady = true;
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(smoothLat!, smoothLng!), zoom: 19, tilt: 65, bearing: smoothBearing ?? pos.heading)));
      }

      final currentLoc = LatLng(smoothLat!, smoothLng!);
      final bearing = smoothBearing ?? pos.heading;
      final dest = LatLng(widget.targetLat, widget.targetLng);
      final distToDest = calcDistance(currentLoc, dest);

      setState(() {
        remainingDistanceText = _formatDistance(distToDest);
        _updateNavMarker(currentLoc, bearing);
      });

      _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLoc, zoom: 19, tilt: 65, bearing: bearing)));

      // Arrival
      if (distToDest < 30 && !hasArrived) {
        setState(() {
          hasArrived = true;
          currentInstruction = '🎉 Hedefe ulaştınız!';
          remainingDistanceText = '0 m';
        });
        _speak('Hedefe ulaştınız. ${widget.targetName} burada.');
        navigationStream?.cancel();
        _showArrivalDialog();
        return;
      }

      // Proactivity
      if (navGPSReady && currentStepIndex < steps.length - 1) {
        final next = steps[currentStepIndex + 1];
        final nLat = next['start_location']['lat'] as double;
        final nLng = next['start_location']['lng'] as double;
        final dN = calcDistance(currentLoc, LatLng(nLat, nLng));
        if (dN < 30) {
          setState(() {
            currentStepIndex++;
            currentInstruction = removeHtml(steps[currentStepIndex]['html_instructions'] ?? '');
            currentStepDistance = steps[currentStepIndex]['distance']?['text'] ?? '';
          });
          if (currentStepIndex != lastSpokenStep) {
            _speak('Hızlıca $currentInstruction');
            lastSpokenStep = currentStepIndex;
          }
        }
      }

      // Recalc
      if (_distanceToPolyline(currentLoc) > 70) _recalculateLocal(currentLoc);
    });
  }

  Future<void> _recalculateLocal(LatLng userLoc) async {
    if (isRecalculating) return;
    if (lastRecalcTime != null && DateTime.now().difference(lastRecalcTime!).inSeconds < 20) return;
    setState(() => isRecalculating = true);
    lastRecalcTime = DateTime.now();
    _speak('Rotadan sapıldı. Yeniden hesaplanıyor.');
    try {
      final routes = await RouteService().getAlternativeRoutes(userLoc, LatLng(widget.targetLat, widget.targetLng), mode: _travelMode);
      if (routes.isNotEmpty && mounted) {
        setState(() {
          _alternativeRoutes = routes;
          _selectedRouteIndex = 0;
          applyRouteData(routes[0], 0, _alternativeRoutes, _polylines, _travelMode);
          _speak('Yeni rota hazır.');
        });
      }
    } catch (_) {} finally { if (mounted) setState(() => isRecalculating = false); }
  }

  void _updateNavMarker(LatLng pos, double bearing) {
    final icon = _travelMode == 'driving' ? (_carMarkerIcon ?? BitmapDescriptor.defaultMarker) : (_walkMarkerIcon ?? BitmapDescriptor.defaultMarker);
    _markers.removeWhere((m) => m.markerId.value == 'user_nav_marker');
    _markers.add(Marker(markerId: const MarkerId('user_nav_marker'), position: pos, rotation: bearing, anchor: const Offset(0.5, 0.5), icon: icon, zIndex: 999, flat: true));
  }

  Future<void> _speak(String text) async {
    if (!_isTtsEnabled || text.isEmpty || _isSpeaking) return;
    try {
      _isSpeaking = true;
      final bytes = await CloudTtsService.synthesize(text, voiceId: _selectedVoiceId);
      if (bytes != null && mounted) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/tts_current.mp3');
        await file.writeAsBytes(bytes, flush: true);
        
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(file.path), volume: 1.0);
        debugPrint('[TTS] Playing: $text');
      } else {
        debugPrint('[TTS] Bytes null for: $text');
      }
    } catch (e) {
      debugPrint('[TTS Error] $e');
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  void _applyVoice(String genderOrId) {
    if (!mounted) return;
    final isGender = genderOrId == 'female' || genderOrId == 'male' || genderOrId == 'off';
    setState(() {
      if (genderOrId == 'off') {
        _isTtsEnabled = false;
        _selectedVoiceGender = 'off';
      } else if (isGender) {
        _isTtsEnabled = true;
        _selectedVoiceGender = genderOrId;
        _selectedVoiceId = genderOrId == 'male' ? CloudTtsService.defaultMaleVoiceId : CloudTtsService.defaultFemaleVoiceId;
      } else {
        _isTtsEnabled = true;
        _selectedVoiceId = genderOrId;
        final v = CloudTtsService.getVoiceById(genderOrId);
        if (v != null) _selectedVoiceGender = v['id'].toString().toLowerCase().contains('male') ? 'male' : 'female';
      }
    });
    if (genderOrId == 'off') _audioPlayer.stop();
    else _speak('Ses ayarlarınız güncellendi.');
  }

  double _distanceToPolyline(LatLng point) {
    if (routePoints.isEmpty) return 0;
    double minDist = double.infinity;
    final subset = routePoints.length > 50 ? routePoints.sublist(max(0, currentStepIndex * 3), min(routePoints.length, currentStepIndex * 3 + 50)) : routePoints;
    for (final p in subset) {
      final d = calcDistance(point, p);
      if (d < minDist) minDist = d;
    }
    return minDist;
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toInt()} m';
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
            const SizedBox(height: 20),
            Text('Hedefe Ulaştınız!', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () { Navigator.pop(ctx); stopNavigationLogic(_audioPlayer, () => setState(() {})); _initRoute(); }, child: const Text('Tamam')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isNavigating ? null : AppBar(title: Text('HayatEli Navigasyon', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Colors.white.withOpacity(0.9), elevation: 0),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(widget.targetLat, widget.targetLng), zoom: 15),
            polylines: _polylines, markers: _markers, mapType: _currentMapType,
            myLocationEnabled: !isNavigating, myLocationButtonEnabled: false, trafficEnabled: _isTrafficEnabled,
            onMapCreated: (c) => _mapController = c,
          ),

          // Üst Mod Sekmeleri
          if (!isNavigating)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 0, right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _modeChip('Sürüş', Icons.directions_car_filled_rounded, 'driving'),
                    const SizedBox(width: 12),
                    _modeChip('Yürüyüş', Icons.directions_walk_rounded, 'walking'),
                  ],
                ),
              ),
            ),

          // Sağ FAB Grubu
          NavigationFabGroup(
            isNavigating: isNavigating,
            isTrafficEnabled: _isTrafficEnabled,
            isTtsEnabled: _isTtsEnabled,
            onTrafficToggle: () => setState(() => _isTrafficEnabled = !_isTrafficEnabled),
            onVoiceTap: () => NavigationWidgets.showVoiceSelector(context: context, selectedVoiceId: _selectedVoiceId, selectedVoiceGender: _selectedVoiceGender, onVoiceSelected: _applyVoice),
            onLocationTap: () async {
              final p = await Geolocator.getCurrentPosition();
              _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude)));
            },
            onMapTypeTap: () => setState(() => _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal),
          ),

          // Alt Başlat / Bilgi Paneli
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
              child: isNavigating ? _buildNavPanel() : _buildStartPanel(),
            ),
          ),
          
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _modeChip(String label, IconData icon, String mode) => GestureDetector(
    onTap: () { if (_travelMode != mode) { setState(() => _travelMode = mode); _initRoute(); } },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: _travelMode == mode ? const Color(0xFF1A73E8) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1A73E8))),
      child: Row(children: [Icon(icon, color: _travelMode == mode ? Colors.white : const Color(0xFF1A73E8), size: 18), const SizedBox(width: 8), Text(label, style: GoogleFonts.outfit(color: _travelMode == mode ? Colors.white : const Color(0xFF1A73E8), fontWeight: FontWeight.bold))]),
    ),
  );

  Widget _buildStartPanel() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(durationText, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.green.shade700)),
          Text(distanceText, style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
      ElevatedButton.icon(
        onPressed: _startLocalNavigation,
        icon: const Icon(Icons.navigation_rounded, size: 24),
        label: Text('BAŞLAT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 6,
          shadowColor: const Color(0xFF1A73E8).withOpacity(0.4),
        ),
      ),
    ],
  );

  Widget _buildNavPanel() {
    return NavigationWidgets.buildNavigationInfoPanel(
      context: context,
      currentInstruction: currentInstruction,
      currentStepDistance: currentStepDistance,
      remainingDistance: remainingDistanceText,
      duration: durationText,
      isRecalculating: isRecalculating,
      onStopNavigation: () => stopNavigationLogic(_audioPlayer, () => setState(() {})),
      onShowSteps: () => NavigationWidgets.showStepsBottomSheet(context: context, steps: steps, currentStepIndex: currentStepIndex, isNavigating: isNavigating),
      onShowAlternativeRoutes: () => NavigationWidgets.showAlternativeRoutes(context: context, routes: _alternativeRoutes, selectedIndex: _selectedRouteIndex, onRouteSelected: (i) {
        setState(() { _selectedRouteIndex = i; applyRouteData(_alternativeRoutes[i], i, _alternativeRoutes, _polylines, _travelMode); });
      }),
    );
  }
}
