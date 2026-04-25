import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/sign_in_controller.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'sign_up.dart';
import 'main_scaffold.dart';
import '../widgets/auth/sign_in/email_form.dart';
import '../widgets/auth/sign_in/phone_form.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailOtpController = TextEditingController();

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedDialCode = +90';'

  static const _kDarkRed = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(signInControllerProvider.notifier).clearError();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailOtpController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
      (route) => false,
    );
  }

  Future<void> _handleEmailAction() async {
    final controller = ref.read(signInControllerProvider.notifier);
    
    if (!_emailFormKey.currentState!.validate()) return;
    
    final success = await controller.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    if (success) _navigateToHome();
  }

  Future<void> _handlePhoneAction() async {
    final controller = ref.read(signInControllerProvider.notifier);
    final state = ref.read(signInControllerProvider);

    if (!state.isPhoneOtpSent) {
      if (!_phoneFormKey.currentState!.validate()) return;
      final fullPhone = Validators.formatPhone(_phoneController.text.trim(), _selectedDialCode);
      await controller.sendPhoneOtp(fullPhone);
    } else {
      if (state.isPhoneOtpExpired) {
        controller.resetPhoneOtpState();
        _otpController.clear();
      } else {
        final success = await controller.verifyPhoneOtp(_otpController.text.trim());
        if (success) _navigateToHome();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signInControllerProvider);
    final authController = ref.read(signInControllerProvider.notifier);

    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && mounted) {
        if (_tabController.index == 0) {
          if (next.value!.emailVerified) _navigateToHome();
        } else {
          _navigateToHome();
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/giris-yap-kapak.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter, 
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text('HAYATELİ',
                    style: GoogleFonts.outfit(
                        fontSize: 32, fontWeight: FontWeight.w900, color: _kDarkRed, letterSpacing: 2.0)),
                Text('Hesabına Giriş Yap',
                    style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: _kDarkRed)),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFFE53935),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFFE53935),
                        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                        tabs: const [
                          Tab(icon: Icon(Icons.email_outlined), text: 'E-Posta'),
                          Tab(icon: Icon(Icons.phone_outlined), text: 'Telefon'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: Alignment.topCenter,
                              child: _tabController.index == 0
                                  ? SignInEmailForm(
                                      formKey: _emailFormKey,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                    )
                                  : SignInPhoneForm(
                                      formKey: _phoneFormKey,
                                      phoneController: _phoneController,
                                      otpController: _otpController,
                                      selectedDialCode: _selectedDialCode,
                                      otpSent: authState.isPhoneOtpSent,
                                      otpExpired: authState.isPhoneOtpExpired,
                                      secondsLeft: authState.phoneSecondsLeft,
                                      onDialCodeChanged: (val) {
                                        if (val != null) setState(() => _selectedDialCode = val);
                                      },
                                      onResetOtp: () {
                                        authController.resetPhoneOtpState();
                                        _otpController.clear();
                                      },
                                    ),
                            ),
                            if (authState.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(authState.errorMessage!,
                                        style: GoogleFonts.outfit(color: Colors.red.shade800, fontSize: 13)),
                                  ),
                                ]),
                              ),
                            ],

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : () {
                                        if (_tabController.index == 0) {
                                          _handleEmailAction();
                                        } else {
                                          _handlePhoneAction();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kDarkRed, 
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(
                                        _tabController.index == 0
                                            ? 'GİRİŞ YAP'
                                            : (authState.isPhoneOtpSent
                                                ? (authState.isPhoneOtpExpired ? 'TEKRAR GÖNDER' : 'KODU DOĞRULA')
                                                : 'SMS GÖNDER'),
                                        style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.2)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Hesabın yok mu? ',
                                    style: GoogleFonts.outfit(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => Navigator.pushReplacement(
                                      context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 12, top: 12, bottom: 12),
                                    child: Text('Kayıt Ol',
                                        style: GoogleFonts.outfit(
                                            color: _kDarkRed,
                                            fontWeight: FontWeight.w900,
                                            decoration: TextDecoration.underline,
                                            decorationColor: _kDarkRed)),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}