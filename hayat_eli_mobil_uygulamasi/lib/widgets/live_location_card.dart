import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';

class LiveLocationCard extends ConsumerWidget {
  const LiveLocationCard({super.key});

  void _showGpsBottomSheet(BuildContext context, WidgetRef ref, bool isPermanentlyDenied) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 16),

              Text(
                isPermanentlyDenied ? 'Konum İzni Kapalı' : 'Konum Servisi Kapalı',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),

              Text(
                isPermanentlyDenied
                    ? 'Uygulamanın konumunuzu bulabilmesi için lütfen Ayarlar\'dan konum iznini "Her Zaman" veya "Kullanırken" olarak değiştirin.'
                    : 'Acil durumlarda konumunuzun anlık olarak bilinmesi hayat kurtarabilir. Lütfen GPS\'inizi açın.',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (isPermanentlyDenied) {
                      await Geolocator.openAppSettings();
                    } else {
                      await Geolocator.openLocationSettings();
                    }
                    await ref.read(locationProvider.notifier).checkLocationAfterSettings();
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: Text(
                    isPermanentlyDenied ? 'Uygulama Ayarlarına Git' : 'GPS Ayarlarını Aç',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Şimdi Değil', style: GoogleFonts.outfit(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    ref.listen(locationProvider, (prev, next) {
      if ((prev?.needsLocationPermission != true) && next.needsLocationPermission) {
        final isPermanentlyDenied = next.error?.contains('kalıcı') == true;
        _showGpsBottomSheet(context, ref, isPermanentlyDenied);
      }
    });

    final bool gpsOff = locationState.needsLocationPermission;
    final String? displayAddress = locationState.address ?? locationState.lastKnownAddress;

    return GestureDetector(
      onTap: gpsOff ? () => _showGpsBottomSheet(context, ref, false) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gpsOff ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gpsOff ? Colors.orange.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              gpsOff ? Icons.location_off : Icons.location_on,
              color: gpsOff ? Colors.orange : Colors.redAccent,
              size: 28,
            ),
            const SizedBox(height: 8),

            if (locationState.isLoading && displayAddress == null)
              const Text(
                "Konum Aranıyor...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              )
            else if (gpsOff && displayAddress != null) ...[
              Text(
                "📍 Son Bilinen Konum",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayAddress,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.orange.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "GPS açık değil • Açmak için dokun",
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.orange.shade600),
              ),
            ] else if (gpsOff) ...[
              Text(
                "GPS Kapalı",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange),
              ),
              const SizedBox(height: 4),
              Text(
                "Açmak için dokun",
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.orange.shade600),
              ),
            ] else
              Text(
                displayAddress ?? "Bilinmeyen Konum",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: const Color(0xFFB71C1C),
                ),
                textAlign: TextAlign.center,
              ),

            if (locationState.isLoading && displayAddress == null) ...[
              const SizedBox(height: 4),
              const Text(
                "112'ye bildirmek için adresiniz saptanıyor",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
