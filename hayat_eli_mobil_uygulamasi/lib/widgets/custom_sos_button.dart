import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

class CustomSosButton extends ConsumerStatefulWidget {
  const CustomSosButton({super.key});

  @override
  ConsumerState<CustomSosButton> createState() => _CustomSosButtonState();
}

class _CustomSosButtonState extends ConsumerState<CustomSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  void _showSosConfirmationDialog() {
    _pulseController.stop();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                const Text(
                  "112 Acil Servis Aranıyor",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bu aramayı kimin için yapıyorsunuz?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); 
                    _startSosCountdown(isForSelf: true); 
                  },
                  child: const Text("KENDİM İÇİN (SMS Gönder ve Ara)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); 
                    _startSosCountdown(isForSelf: false); 
                  },
                  child: const Text("BAŞKASI İÇİN (Sadece Ara)", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context); 
                    _pulseController.repeat(reverse: true);
                  },
                  child: const Text("İptal Et (Yanlışlıkla Bastım)", style: TextStyle(color: Colors.grey)),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }
  void _startSosCountdown({required bool isForSelf}) {
    int countdown = 5;
    bool isCancelled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Timer.periodic(const Duration(seconds: 1), (timer) {
              if (isCancelled) {
                timer.cancel();
                return;
              }
              
              if (countdown > 1) {
                setState(() {
                  countdown--;
                });
              } else {
                timer.cancel();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                _executeSosAction(context: context, isForSelf: isForSelf);
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Center(
                child: Icon(Icons.warning, color: Colors.red, size: 64),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ACİL DURUM ÇAĞRISI BAŞLIYOR",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$countdown",
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "İptal etmek için süreniz devam ediyor...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      isCancelled = true;
                      Navigator.pop(context); 
                      _pulseController.repeat(reverse: true);
                    },
                    child: const Text("İPTAL ET (Yalnızca Test)"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  
  Future<void> _executeSosAction({required BuildContext context, required bool isForSelf}) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationText)}";
      
      String message = "ACİL DURUM! Acil yardıma ihtiyacım var.\n"
          "Şu anki konumum: $googleMapsUrl";
          
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: emergencyPhone,
        queryParameters: <String, String>{
          'body': message,
        },
      );
      
      try {
        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      } catch (e) {
        debugPrint("SMS Başlatılamadı: $e");
      }
    } 

    if (!isForSelf) {
      try {
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Arama başlatılamadı. Lütfen manuel olarak 112'yi tuşlayınız.")),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Arama sırasında bir hata oluştu.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _showSosConfirmationDialog,
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C), 
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "112 ACİL",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.phone_in_talk,
                color: Colors.white,
                size: 48,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
