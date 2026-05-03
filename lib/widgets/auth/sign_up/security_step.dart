import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityStep extends StatelessWidget {
  final bool emailVerified;

  const SecurityStep({super.key, required this.emailVerified});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
        ),
        child: Column(children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          Text('Neredeyse Hazır!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text('E-posta ve kimlik bilgileriniz başarıyla işlendi. Kaydı tamamlamak için aşağıdaki butona basın.',
            textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey.shade700, fontSize: 15)),
          const SizedBox(height: 32),
          if (!emailVerified)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Dikkat: E-posta henüz doğrulanmamış. Lütfen linke tıklayın.',
                  style: GoogleFonts.outfit(color: Colors.red.shade900, fontSize: 12))),
              ]),
            ),
        ]),
      ),
    );
  }
}
