import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lastAddressKey = 'last_known_address';

class LocationState {
  final bool isLoading;
  final String? address;
  final String? lastKnownAddress; 
  final String? error;
  final bool needsLocationPermission; 

  LocationState({
    this.isLoading = false,
    this.address,
    this.lastKnownAddress,
    this.error,
    this.needsLocationPermission = false,
  });

  LocationState copyWith({
    bool? isLoading,
    String? address,
    String? lastKnownAddress,
    String? error,
    bool? needsLocationPermission,
    bool clearError = false,
  }) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      address: address ?? this.address,
      lastKnownAddress: lastKnownAddress ?? this.lastKnownAddress,
      error: clearError ? null : (error ?? this.error),
      needsLocationPermission: needsLocationPermission ?? this.needsLocationPermission,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  LocationState build() {
    ref.onDispose(() {
      _serviceStatusStreamSubscription?.cancel();
      _positionStreamSubscription?.cancel();
    });

    _loadLastKnownAddress();

    _determinePosition();

    if (!kIsWeb) {
      _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
        if (status == ServiceStatus.enabled) {
          state = state.copyWith(needsLocationPermission: false, clearError: true);
          _determinePosition();
        } else {
          state = state.copyWith(
            isLoading: false,
            needsLocationPermission: true,
          );
          _positionStreamSubscription?.cancel();
        }
      });
    }

    return LocationState(isLoading: false);
  }

  Future<void> _loadLastKnownAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_lastAddressKey);
    if (saved != null && saved.isNotEmpty) {
      state = state.copyWith(lastKnownAddress: saved);
    }
  }

  Future<void> _saveLastKnownAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastAddressKey, address);
  }

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, needsLocationPermission: false, clearError: true);
    await _determinePosition();
  }

  Future<void> checkLocationAfterSettings() async {
    await refreshLocation();
  }

  Future<void> _determinePosition() async {
    await _positionStreamSubscription?.cancel();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isLoading: false, needsLocationPermission: true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(isLoading: false, needsLocationPermission: true);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(isLoading: false, needsLocationPermission: true, error: 'Konum izni kalıcı olarak reddedildi.');
      return;
    }

    state = state.copyWith(isLoading: true, needsLocationPermission: false);

    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      forceLocationManager: true, 
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) => _processPosition(position),
      onError: (e) {
        state = state.copyWith(isLoading: false, error: 'Canlı konum alınırken hata.');
      },
    );

    try {
      final initial = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
      if (state.address == null) {
        await _processPosition(initial);
      }
    } catch (_) {
      // Eğer tek atış başarısız olursa, stream devralacaktır, o yüzden sessizce geç
    }
  }

  Future<void> _processPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final parts = <String>[];
        if (place.street?.isNotEmpty == true) parts.add(place.street!);
        if (place.subLocality?.isNotEmpty == true && place.subLocality != place.street) parts.add(place.subLocality!);
        if (place.subAdministrativeArea?.isNotEmpty == true) parts.add(place.subAdministrativeArea!);
        if (place.administrativeArea?.isNotEmpty == true) parts.add(place.administrativeArea!);
        if (place.postalCode?.isNotEmpty == true) parts.add(place.postalCode!);
        if (place.country?.isNotEmpty == true) parts.add(place.country!);

        final formattedAddress = parts.join(', ');

        await _saveLastKnownAddress(formattedAddress);

        state = state.copyWith(
          isLoading: false,
          address: formattedAddress,
          lastKnownAddress: formattedAddress,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Adres çözülemedi.');
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);
