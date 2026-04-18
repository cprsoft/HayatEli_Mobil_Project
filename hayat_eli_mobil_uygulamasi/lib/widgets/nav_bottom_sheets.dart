import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/cloud_tts_service.dart';

/// Navigasyon alt panelleri (Adımlar, Rotalar, Ses Seçici).
class NavigationWidgets {
  static String _removeAllHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
  }

  /// ─── Adım Adım Liste ───
  static void showStepsBottomSheet({
    required BuildContext context,
    required List<dynamic> steps,
    required int currentStepIndex,
    required bool isNavigating,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 14),
            Text('Adım Adım Yol Tarifi', style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                itemCount: steps.length,
                separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100),
                itemBuilder: (ctx, i) {
                  final step = steps[i];
                  final clean = _removeAllHtmlTags(step['html_instructions'] ?? '');
                  final dist = step['distance']?['text'] ?? '';
                  final isActive = i == currentStepIndex && isNavigating;
                  return ListTile(
                    tileColor: isActive ? Colors.blue.shade50 : null,
                    shape: isActive ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) : null,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isActive ? Colors.blue : Colors.red.shade50,
                      child: Text('${i + 1}', style: GoogleFonts.outfit(fontSize: 12, color: isActive ? Colors.white : Colors.red.shade700, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(clean, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600)),
                    trailing: Text(dist, style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─── Ses Seçici Menü ───
  static void showVoiceSelector({
    required BuildContext context,
    required String selectedVoiceId,
    required String selectedVoiceGender,
    required Function(String) onVoiceSelected,
  }) {
    String localId = selectedVoiceId;
    String localGender = selectedVoiceGender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Ses Asistanı Seçimi', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
              const SizedBox(height: 4),
              Text('Navigasyon için en doğal Türkçe sesi seçin', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _voiceMainTile(ctx, 'off', Icons.volume_off_rounded, 'Sesi Kapat', 'Navigasyon sessiz devam eder', Colors.grey, localGender == 'off', (id) {
                      set(() { localId = id; localGender = 'off'; });
                      onVoiceSelected(id);
                    }),
                    const SizedBox(height: 24),
                    _voiceCategoryHeader('Kadın Sesleri', '👩'),
                    ...CloudTtsService.femaleVoices.map((v) => _voiceSubTile(v, localId, (id) {
                      final voice = CloudTtsService.getVoiceById(id);
                      set(() { localId = id; localGender = voice?['id'].toString().contains('male') == true ? 'male' : 'female'; });
                      onVoiceSelected(id);
                    })),
                    const SizedBox(height: 24),
                    _voiceCategoryHeader('Erkek Sesleri', '👨'),
                    ...CloudTtsService.maleVoices.map((v) => _voiceSubTile(v, localId, (id) {
                      final voice = CloudTtsService.getVoiceById(id);
                      set(() { localId = id; localGender = voice?['id'].toString().contains('male') == true ? 'male' : 'female'; });
                      onVoiceSelected(id);
                    })),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _voiceCategoryHeader(String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.blue.shade800)),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.blue.withOpacity(0.1))),
        ],
      ),
    );
  }

  static Widget _voiceMainTile(BuildContext ctx, String id, IconData icon, String title, String sub, Color color, bool isSelected, Function(String) onVoiceSelected) {
    return InkWell(
      onTap: () {
        onVoiceSelected(id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isSelected ? color : Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? Colors.white : color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(sub, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  static Widget _voiceSubTile(Map<String, dynamic> v, String selectedVoiceId, Function(String) onVoiceSelected) {
    final isSelected = selectedVoiceId == v['id'];
    final quality = v['quality'] as String;
    final isHD = quality.contains('HD');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade100, width: 1.5),
      ),
      child: ListTile(
        onTap: () => onVoiceSelected(v['id']),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(v['name'][0], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
        ),
        title: Row(
          children: [
            Text(v['name'], style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: isHD ? Colors.orange.shade100 : Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
              child: Text(quality, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isHD ? Colors.orange.shade800 : Colors.green.shade800)),
            ),
          ],
        ),
        subtitle: Text(v['description'], style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.blue) : null,
      ),
    );
  }

  /// ─── Alternatif Rota Paneli ───
  static void showAlternativeRoutes({
    required BuildContext context,
    required List<dynamic> routes,
    required int selectedIndex,
    required Function(int) onRouteSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('Alternatif Rotalar', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ...List.generate(routes.length, (i) {
              final r = routes[i];
              final isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () {
                  onRouteSelected(i);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A73E8).withOpacity(0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? const Color(0xFF1A73E8) : Colors.grey.shade200, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.route_rounded, color: isSelected ? const Color(0xFF1A73E8) : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rota ${i + 1}${i == 0 ? ' (Önerilen)' : ''}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF1A73E8) : Colors.black87)),
                            Text('${r['duration']} · ${r['distance']}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF1A73E8)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// ─── Navigasyon Alt Bilgi Paneli (Sabit) ───
  static Widget buildNavigationInfoPanel({
    required BuildContext context,
    required String currentInstruction,
    required String currentStepDistance,
    required String remainingDistance,
    required String duration,
    required bool isRecalculating,
    required VoidCallback onStopNavigation,
    required VoidCallback onShowSteps,
    required VoidCallback onShowAlternativeRoutes,
  }) {
    final now = DateTime.now();
    // Süreyi parse et (örn: "5 dk")
    int minutes = 0;
    try {
      minutes = int.parse(duration.split(' ')[0]);
    } catch (_) {}
    final arrivalTime = DateFormat('HH:mm').format(now.add(Duration(minutes: minutes)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rota Hesaplama Uyarısı
          if (isRecalculating)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                  const SizedBox(width: 12),
                  Text('Rota yeniden hesaplanıyor...', style: GoogleFonts.outfit(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          // Talimat Bölümü
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1A73E8).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.navigation_rounded, color: Color(0xFF1A73E8), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentInstruction, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (currentStepDistance.isNotEmpty)
                      Text(currentStepDistance, style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A73E8), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onShowSteps,
                icon: const Icon(Icons.format_list_bulleted_rounded, color: Colors.black54),
              ),
            ],
          ),
          const Divider(height: 32),

          // Alt Bilgi Bölümü (Varış Süresi, Mesafe, Süre)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(duration, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green.shade700)),
                    Text('$remainingDistance · Varış: $arrivalTime', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                children: [
                  _circleBtn(Icons.alt_route_rounded, Colors.black87, onShowAlternativeRoutes, tooltip: 'Rotalar'),
                  const SizedBox(width: 10),
                  _circleBtn(Icons.format_list_bulleted_rounded, Colors.black87, onShowSteps, tooltip: 'Adımlar'),
                  const SizedBox(width: 10),
                  _circleBtn(Icons.close_rounded, Colors.white, onStopNavigation, bgColor: Colors.red.shade600, tooltip: 'Bitir'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _circleBtn(IconData icon, Color color, VoidCallback onTap, {Color bgColor = Colors.white, String? tooltip}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
