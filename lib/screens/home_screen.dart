import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:another_telephony/telephony.dart';
import '../widgets/custom_sos_button.dart';
import '../widgets/live_location_card.dart';
import '../services/auth/auth_service.dart';
import 'sign_in.dart';
import 'main_scaffold.dart';
import 'first_aid_guide_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      await Telephony.instance.requestPhonePermissions;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    final userProfile = userProfileAsync.asData?.value;
    final userName = userProfile?.firstName ?? "";
    final userLastName = userProfile?.lastName ?? "";
    final fullName = userName.isNotEmpty ? "$userName $userLastName".trim() : "Kullanıcı";
    final profilePic = userProfile?.profilePictureUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        toolbarHeight: 70,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.redAccent, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          children: [
            Text(
              "HAYATELİ",
              style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            if (userName.isNotEmpty)
              Text(
                "Merhaba, $userName",
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(3);
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                backgroundImage: (profilePic != null && profilePic.startsWith('http'))
                    ? NetworkImage(profilePic)
                    : null,
                child: (profilePic == null || !profilePic.startsWith('http'))
                    ? Icon(Icons.person, color: Colors.red.shade800, size: 20)
                    : null,
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: (profilePic != null && profilePic.startsWith('http')) 
                        ? NetworkImage(profilePic) : null,
                    child: (profilePic == null || !profilePic.startsWith('http')) 
                        ? const Icon(Icons.person, size: 35, color: Colors.redAccent) : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    fullName, 
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "HayatEli Kullanıcısı", 
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.settings, 'Ayarlar'),
                  _drawerItem(Icons.privacy_tip, 'Gizlilik Politikası'),
                  _drawerItem(Icons.feedback, 'Bize Ulaşın'),
                  _drawerItem(Icons.info, 'Uygulama Hakkında'),
                  _drawerItem(Icons.menu_book, 'Kullanım Kılavuzu'),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Çıkış Yap', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.redAccent)),
              onTap: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('lib/assets/images/giris-yap-kapak.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withValues(alpha: 0.90), 
                        BlendMode.lighten,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FirstAidGuideScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.menu_book_rounded, color: Colors.blueAccent),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Olay yerinde ne yapmanız gerektiğini öğrenin",
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "İlk Yardım Rehberini İncele",
                                        style: GoogleFonts.outfit(
                                          color: Colors.blueAccent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.blueAccent),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      const CustomSosButton(),
                      const SizedBox(height: 35),
                      Text(
                        "Merhaba yardıma mı ihtiyacınız var? Yukarıdaki butona basın.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFB71C1C),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 32.0, left: 24.0, right: 24.0),
                        child: LiveLocationCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
      onTap: () {},
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

