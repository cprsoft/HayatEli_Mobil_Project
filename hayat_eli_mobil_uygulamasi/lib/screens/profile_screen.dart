import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'sign_in.dart';
import 'main_scaffold.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _kRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'PROFİLİM',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: _kRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          if (ref.watch(authStateProvider).value != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _showLogoutDialog(context, ref),
            ),
        ],
      ),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('Profil bulunamadı.'));
          return _buildProfileContent(context, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: _kRed)),
        error: (e, __) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel profile) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: _kRed,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          padding: const EdgeInsets.only(top: 16, bottom: 28),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: (profile.profilePictureUrl?.isNotEmpty == true)
                    ? NetworkImage(profile.profilePictureUrl!) : null,
                child: (profile.profilePictureUrl?.isEmpty != false)
                    ? const Icon(Icons.person, size: 60, color: _kRed) : null,
              ),
              const SizedBox(height: 12),
              Text(
                profile.fullName.toUpperCase(),
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(profile.bloodType, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
          ),
        ),

        // ─── KAYDIRILABİLİR İÇERİK ───
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('KİMLİK BİLGİLERİ'),
                _infoCard([
                  _infoRow(Icons.badge_outlined, 'T.C. Kimlik', '***********'),
                  _infoRow(Icons.calendar_today_outlined, 'Doğum Tarihi', DateFormat('dd.MM.yyyy').format(profile.birthDate)),
                  _infoRow(Icons.wc_outlined, 'Cinsiyet', profile.gender),
                ]),

                const SizedBox(height: 25),
                _sectionTitle('İLETİŞİM BİLGİLERİ'),
                _infoCard([
                  _infoRow(Icons.email_outlined, 'E-posta', profile.email),
                  _infoRow(Icons.phone_outlined, 'Telefon', profile.phone),
                ]),

                const SizedBox(height: 25),
                _sectionTitle('SAĞLIK BİLGİLERİ'),
                _infoCard([
                  _infoRow(Icons.monitor_heart_outlined, 'Kronik Hastalıklar', profile.chronicDiseases ?? 'Belirtilmedi'),
                  _infoRow(Icons.science_outlined, 'Alerjiler', profile.allergies ?? 'Belirtilmedi'),
                  _infoRow(Icons.medication_outlined, 'Kullanılan İlaçlar', profile.currentMedications ?? 'Belirtilmedi'),
                ]),

                if (profile.emergencyContacts.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  _sectionTitle('ACİL DURUM KİŞİLERİ'),
                  ...profile.emergencyContacts.map((contact) => _infoCard([
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _kRed.withValues(alpha: 0.1),
                            backgroundImage: contact.profilePictureUrl != null ? NetworkImage(contact.profilePictureUrl!) : null,
                            child: contact.profilePictureUrl == null 
                                ? Icon(Icons.person, size: 20, color: _kRed.withValues(alpha: 0.7))
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.relationship, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(contact.name, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
                                Text(contact.phone, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ], marginBottom: 8)),
                ],

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'HAYATELİ tüm hakları saklıdır.',
                    style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.grey.shade800, fontSize: 13, letterSpacing: 0.8)),
    );
  }

  Widget _infoCard(List<Widget> children, {double marginBottom = 0}) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: _kRed.withValues(alpha: 0.7)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              ref.read(bottomNavIndexProvider.notifier).setIndex(0);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
