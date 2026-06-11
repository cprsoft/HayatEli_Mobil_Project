import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionManager {
  static Future<void> requestInitialPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location, 
      Permission.phone,    
      Permission.microphone,
      Permission.sms,      
    ].request();

    bool isAnyPermissionDenied = false;
    bool isPermanentlyDenied = false;

    statuses.forEach((permission, status) {
      if (status.isDenied) {
        isAnyPermissionDenied = true;
      }
      if (status.isPermanentlyDenied) { 
        isPermanentlyDenied = true;
      }
    });

    if (isPermanentlyDenied) {
      _showSettingsDialog(context);
    } 
    else if (isAnyPermissionDenied) {
      debugPrint("Kullanıcı bazı izinleri reddetti, daha sonra tekrar sorulabilir.");
    } else {
      debugPrint("Tüm hayati izinler başarıyla alındı!");
    }
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Kritik İzinler Gerekli", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "HayatEli'nin acil durumlarda hayatınızı kurtarabilmesi için Konum, Telefon ve Mikrofon izinlerine ihtiyacı var.\n\n"
            "İzinleri kalıcı olarak reddettiğiniz için lütfen 'Ayarlar' butonuna basarak bu izinleri manuel olarak açın.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Daha Sonra", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings(); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
              child: const Text("Ayarları Aç", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
