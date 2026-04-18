import 'package:flutter/material.dart';

/// Navigasyon ekranındaki sağ taraf buton grubu (FAB).
class NavigationFabGroup extends StatelessWidget {
  final bool isNavigating;
  final bool isTrafficEnabled;
  final bool isTtsEnabled;
  final VoidCallback onTrafficToggle;
  final VoidCallback onVoiceTap;
  final VoidCallback onLocationTap;
  final VoidCallback onMapTypeTap;

  const NavigationFabGroup({
    super.key,
    required this.isNavigating,
    required this.isTrafficEnabled,
    required this.isTtsEnabled,
    required this.onTrafficToggle,
    required this.onVoiceTap,
    required this.onLocationTap,
    required this.onMapTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: isNavigating ? 235 : 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fabBtn(
            Icons.layers_outlined,
            Colors.black87,
            onMapTypeTap,
            tooltip: 'Harita Türü',
          ),
          const SizedBox(height: 10),
          _fabBtn(
            Icons.threed_rotation_rounded,
            Colors.orange.shade700,
            onTrafficToggle,
            tooltip: '3D Görünüm',
            bgColor: Colors.orange.shade50,
          ),
          const SizedBox(height: 10),
          _fabBtn(
            Icons.my_location_rounded,
            Colors.blue,
            onLocationTap,
            tooltip: 'Konumum',
          ),
          const SizedBox(height: 10),
          _fabBtn(
            isTrafficEnabled ? Icons.traffic_rounded : Icons.traffic_outlined,
            isTrafficEnabled ? Colors.green : Colors.black87,
            onTrafficToggle,
            tooltip: 'Trafik Durumu',
            bgColor: isTrafficEnabled ? Colors.green.shade50 : Colors.white,
          ),
          const SizedBox(height: 10),
          _fabBtn(
            isTtsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            isTtsEnabled ? Colors.blue : Colors.black87,
            onVoiceTap,
            tooltip: 'Sesli Asistan',
            bgColor: isTtsEnabled ? Colors.blue.shade50 : Colors.white,
          ),
          if (!isNavigating) ...[
            const SizedBox(height: 10),
            _fabBtn(
              Icons.gps_fixed_rounded,
              Colors.purple,
              () {
                // Koordinat bulma tetiklemesi (Callback eklenmeli)
                onLocationTap(); 
              },
              tooltip: 'Koordinat Bul',
              bgColor: Colors.purple.shade50,
            ),
          ],
        ],
      ),
    );
  }

  Widget _fabBtn(IconData icon, Color iconColor, VoidCallback onTap,
      {Color bgColor = Colors.white, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        color: bgColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}
