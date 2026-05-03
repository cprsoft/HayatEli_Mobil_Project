import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionManager {
  /// Uygulama ilk açıldığında (veya giriş yapıldıktan sonra) çağrılacak ana fonksiyon
  static Future<void> requestInitialPermissions(BuildContext context) async {
    // 1. İstenen tehlikeli izinlerin listesi (Pop-up çıkartarak sorar)
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location, // GPS (Kaza tespiti ve takip için)
      Permission.phone,    // Telefon (Acil arama için)
      Permission.microphone, // Mikrofon (Sesli komut/dinleme için)
      Permission.sms,      // SMS (Otonom acil durum ihbarı için)
    ].request();

    bool isAnyPermissionDenied = false;
    bool isPermanentlyDenied = false;

    // 2. İzinlerin durumunu kontrol et
    statuses.forEach((permission, status) {
      if (status.isDenied) {
        isAnyPermissionDenied = true;
      }
      if (status.isPermanentlyDenied) { // "BİR DAHA SORMA" diyerek reddedildiyse!
        isPermanentlyDenied = true;
      }
    });

    // 3. Kalıcı olarak reddedildiyse sistem pop-up'ı kilitlenmiştir! Özel taktik uygula:
    if (isPermanentlyDenied) {
      _showSettingsDialog(context);
    } 
    // 4. Sadece ilk kez reddedildiyse
    else if (isAnyPermissionDenied) {
      debugPrint("Kullanıcı bazı izinleri reddetti, daha sonra tekrar sorulabilir.");
    } else {
      debugPrint("Tüm hayati izinler başarıyla alındı!");
    }
  }

  /// Kullanıcıyı doğrudan Android'in "Ayarlar -> HayatEli -> İzinler" menüsüne fırlatır!
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayarak kaçamasın
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
                openAppSettings(); // İŞTE SİHİRLİ KOMUT! Telefonun ayarlarını açar.
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
