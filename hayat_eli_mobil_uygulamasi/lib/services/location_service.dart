import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Konum verisini tutacak State nesnesi
class LocationState {
  final bool isLoading;
  final String? address;
  final String? error;

  LocationState({this.isLoading = false, this.address, this.error});

  LocationState copyWith({bool? isLoading, String? address, String? error}) {
    return LocationState(
      isLoading: isLoading ?? this.isLoading,
      address: address ?? this.address,
      error: error ?? this.error,
    );
  }
}

// Konum işlemlerini yönetecek Notifier
class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    // İlk açılışta hemen izin isteyip konumu almayı dene
    _determinePosition();
    return LocationState(isLoading: true);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // GPS açık mı kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isLoading: false, error: 'Konum servisleri kapalı.');
      return;
    }

    // İzin kontrolü
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(isLoading: false, error: 'Konum izni reddedildi.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
          isLoading: false,
          error: 'Konum izni kalıcı olarak reddedildi, ayarlardan açınız.');
      return;
    }

    // İzinler tamamsa canlı dinlemeyi (Stream) başlat
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Kullanıcı 10 metre yer değiştirince güncelle
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        if (position != null) {
          try {
            // Enlem boylamı açık adrese çevir (Geocoding)
            List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude, position.longitude);

            if (placemarks.isNotEmpty) {
              Placemark place = placemarks[0];
              // Mümkün olan tüm detaylı veriyi (Mahalle, Cadde, İlçe, İl) birleştiriyoruz
              List<String> addressParts = [];
              if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
              if (place.subLocality != null && place.subLocality!.isNotEmpty && place.subLocality != place.street) addressParts.add(place.subLocality!);
              if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) addressParts.add(place.subAdministrativeArea!);
              if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
              
              String formattedAddress = addressParts.join(', ');
              
              state = state.copyWith(isLoading: false, address: formattedAddress, error: null);
            }
          } catch (e) {
            state = state.copyWith(isLoading: false, error: 'Adres çözülemedi.');
          }
        }
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: 'Konum alınırken hata oluştu.');
      },
    );
  }
}

// UI'dan erişeceğimiz Provider
final locationProvider = NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);
