import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_scaffold.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

   
    _scaleController.forward().then((_) => _fadeController.forward());
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFB71C1C), Color(0xFF880E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🎉',
                          style: TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Profiliniz Oluşturuldu!',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Hesabınız ve sağlık profiliniz başarıyla kaydedildi.\n\nAcil bir durumda yanınızda olacağız.',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 48),

                        // Uygulamaya Git Butonu
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward_ios, size: 18),
                            label: Text(
                              'UYGULAMAYA GİT',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFB71C1C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const MainScaffold()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
