import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_sos_button.dart';
import '../widgets/live_location_card.dart';
import '../services/auth_service.dart';
import 'sign_in.dart';
import 'main_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Oturum durumunu dinle
    final authState = ref.watch(authStateProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    final isLoggedIn = authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );
    
    final userProfile = userProfileAsync.asData?.value;
    final userName = userProfile?.firstName ?? "";
    final profilePic = userProfile?.profilePictureUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. ÜST KISIM (APPBAR BÖLGESİ)
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        toolbarHeight: 70,
        centerTitle: true,
        // Sol Üst: Kayıt Teşviki (Eğer giriş yapılmamışsa göster)
        leadingWidth: 120,
        leading: isLoggedIn 
          ? const SizedBox() // Giriş yapılmışsa boşluk
          : Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 16, color: Colors.redAccent),
                    Text(
                      "Giriş / Kayıt",
                      style: GoogleFonts.outfit(
                        color: Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
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
            if (isLoggedIn && userName.isNotEmpty)
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
                // Notifier üzerinden 3. sekmeye (Profil) geçişi tetikleyebiliriz
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
                        Colors.white.withValues(alpha: 0.94), 
                        BlendMode.lighten,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // 2. REHBER KARTI
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            // TODO: İlk yardım eğitim rehberi sayfasına yönlendirilecek
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
                                          // decoration: TextDecoration.underline, // Çizgi kaldırıldı
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
                      
                      const Spacer(),
                      
                      // 3. SOS BUTONU
                      const CustomSosButton(),
                      
                      const SizedBox(height: 20),
                      
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
                      
                      // 4. ALT KISIM (CANLI KONUM BÖLGESİ)
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
}
