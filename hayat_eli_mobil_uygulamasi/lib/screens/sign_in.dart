import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';
import '../utils/validators.dart';
import 'sign_up.dart';
import 'forgot_password_screen.dart';
import 'main_scaffold.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // E-posta formu
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailOtpController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailOtpSent = false;
  bool _emailOtpExpired = false;
  int _emailSecondsLeft = 60;
  String? _generatedEmailOtp; // Gerçek üretilen kod

  // Telefon OTP Giriş — 60 saniye
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _otpExpired = false;
  String? _verificationId;
  String _selectedDialCode = '+90';

  // Geri sayım
  Timer? _otpTimer;
  int _secondsLeft = 60;
  static const int _otpTimeout = 60; // Giriş için 60 saniye

  bool _isLoading = false;
  String? _errorMessage;
  bool _showResendOption = false;

  static const _kRed = Color(0xFFE53935);
  static const _kDarkRed = Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailOtpController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ─── Geri sayım başlat ───
  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _secondsLeft = _otpTimeout;
      _otpExpired = false;
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() => _otpExpired = true);
      }
    });
  }

  // ─── OTP sıfırla (Tekrar Gönder) ───
  void _resetOtp() {
    _otpTimer?.cancel();
    setState(() {
      _otpSent = false;
      _otpExpired = false;
      _secondsLeft = _otpTimeout;
      _otpController.clear();
      _verificationId = null;
    });
  }

  Future<void> _signInWithEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    if (!_emailOtpSent) {
      // 1. ADIM: E-posta ve şifreyi kontrol et
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = ref.read(authServiceProvider);
      // Firebase auth kontrolü (Kayıtlı mı?)
      final error = await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      
      if (error != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
        return;
      }

      // Oturumu hemen kapat (çünkü henüz 6 haneli kodu girmesi gerek)
      await authService.signOut();

      // 2. ADIM: 6 Haneli Kod Gönder
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString(); // 6 haneli rastgele sayı
      _generatedEmailOtp = otp;

      final emailService = ref.read(emailServiceProvider);
      final now = DateTime.now().add(const Duration(minutes: 15));
      final timeStr = DateFormat('HH:mm').format(now);

      final success = await emailService.sendLoginOtp(
        email: _emailController.text.trim(),
        otpCode: otp,
        time: timeStr,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isLoading = false;
          _emailOtpSent = true;
          _emailSecondsLeft = 60;
          _emailOtpExpired = false;
        });
        _startEmailOtpTimer();
        _showMessage('Giriş kodu e-postanıza gönderildi!', isError: false);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'E-posta gönderilemedi. Lütfen sonra tekrar deneyin.';
        });
      }
    } else {
      // 3. ADIM: Kodu doğrula
      if (_emailOtpExpired) {
        setState(() => _errorMessage = 'Kodun süresi doldu.');
        return;
      }
      
      final code = _emailOtpController.text.trim();
      if (code != _generatedEmailOtp) {
        setState(() => _errorMessage = 'Girdiğiniz kod hatalı.');
        return;
      }

      setState(() => _isLoading = true);
      final authService = ref.read(authServiceProvider);
      final error = await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (error == null) {
        _otpTimer?.cancel();
        _navigateToHome();
      } else {
        setState(() => _errorMessage = error);
      }
    }
  }

  void _startEmailOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_emailSecondsLeft > 0) {
          _emailSecondsLeft--;
        } else {
          _emailOtpExpired = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _resendVerificationEmail() async {
    final authService = ref.read(authServiceProvider);
    // Önce giriş yap (sadece doğrulama maili göndermek için)
    await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    // Maili gönder (signIn emailVerified kontrolü olmadan direkt gönder)
    final user = authService.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await authService.signOut();
    }
    if (!mounted) return;
    _showMessage('Doğrulama maili yeniden gönderildi. Lütfen gelen kutunuzu kontrol edin.');
  }

  Future<void> _sendPhoneOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = Validators.formatPhone(_phoneController.text.trim(), _selectedDialCode);
    final authService = ref.read(authServiceProvider);
    await authService.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
          _verificationId = verificationId;
        });
        _startOtpTimer(); // ⏱ 60 saniye başlat
        _showMessage('SMS kodu gönderildi! 60 saniye geçerli.', isError: false);
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
    );
  }

  Future<void> _verifyPhoneOtp() async {
    // Süre dolmuşsa doğrulama yapılamaz
    if (_otpExpired) {
      setState(() =>
        _errorMessage = 'Kodun süresi doldu. Lütfen yeni kod isteyin.');
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = '6 haneli kodu eksiksiz girin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authServiceProvider);
    final error = await authService.verifyPhoneOtp(
      smsCode: otp,
      verificationId: _verificationId,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    } else {
      _otpTimer?.cancel();
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
      (route) => false,
    );
  }

  void _showMessage(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.outfit()),
      backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // 🔔 Otomatik SMS Doğrulama Dinleyici (Android Auto-fill için)
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && mounted) {
        // Eğer e-posta sekmesindeyse, emailVerified kontrolü yap (AuthService'deki signInWithEmail zaten engelliyor ama burası ek katman)
        if (_tabController.index == 0) {
          if (next.value!.emailVerified) _navigateToHome();
        } else {
          // Telefon girişinde direkt ana sayfaya
          _navigateToHome();
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Arka plan fotoğrafı — saf hali, overlay yok
          image: DecorationImage(
            image: AssetImage('lib/assets/images/giris-yap-kapak.jpg'),
            fit: BoxFit.cover,
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
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _kDarkRed,
                        letterSpacing: 2.0)),
                Text('Hesabına Giriş Yap',
                    style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _kDarkRed)),
                const SizedBox(height: 32),

                // Ana Kart
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      // Sekme Bar
                      TabBar(
                        controller: _tabController,
                        labelColor: _kRed,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: _kRed,
                        labelStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        tabs: const [
                          Tab(icon: Icon(Icons.email_outlined), text: 'E-Posta'),
                          Tab(icon: Icon(Icons.phone_outlined), text: 'Telefon'),
                        ],
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          height: _tabController.index == 0 ? 210 : (_otpSent ? 290 : 175),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildEmailForm(),
                              _buildPhoneForm(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hata mesajı
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_errorMessage!,
                                style: GoogleFonts.outfit(
                                    color: Colors.white, fontSize: 13)),
                          ),
                        ]),
                        // E-posta doğrulanmamışsa tekrar gönder
                        if (_showResendOption) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _resendVerificationEmail,
                            child: Text(
                              'Doğrulama mailini tekrar gönder →',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Giriş / Doğrula butonu
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                         : () {
                            if (_tabController.index == 0) {
                              _signInWithEmail();
                            } else {
                              if (_otpSent) {
                                _otpExpired ? _resetOtp() : _verifyPhoneOtp();
                              } else {
                                _sendPhoneOtp();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _kDarkRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _kDarkRed))
                        : Text(
                            _tabController.index == 0
                                ? 'GİRİŞ YAP'
                                : (_otpSent
                                    ? (_otpExpired ? 'TEKRAR GÖNDER' : 'KODU DOĞRULA')
                                    : 'SMS GÖNDER'),
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.2)),
                  ),
                ),

                const SizedBox(height: 18),

                // Kayıt ol linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabın yok mu? ',
                        style: GoogleFonts.outfit(
                            color: _kDarkRed, fontWeight: FontWeight.w600)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const SignUpScreen())),
                      child: Text('Kayıt Ol',
                          style: GoogleFonts.outfit(
                              color: _kDarkRed,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                              decorationColor: _kDarkRed)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── E-posta Formu ──
  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_emailOtpSent,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[\s]'))],
            decoration: _inputDecoration('E-posta', Icons.email_outlined),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 14),
          if (!_emailOtpSent)
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration('Şifre', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Şifre zorunludur.' : null,
            ),
          
          if (!_emailOtpSent)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  'Şifremi Unuttum',
                  style: GoogleFonts.outfit(
                    color: _kDarkRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          if (_emailOtpSent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _emailOtpExpired ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _emailOtpExpired ? 'Süre doldu' : 'Kalan: $_emailSecondsLeft sn',
                    style: GoogleFonts.outfit(fontSize: 12, color: _emailOtpExpired ? Colors.red : Colors.green.shade800),
                  ),
                  if (_emailOtpExpired)
                    GestureDetector(
                      onTap: () => setState(() => _emailOtpSent = false),
                      child: Text('Tekrar Dene', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: _kRed, decoration: TextDecoration.underline)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('6 Haneli E-posta Kodu', Icons.key_outlined),
            ),
          ],
        ],
      ),
    );
  }

  // ── Telefon Formu ──
  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          // Alan Kodu Seçici + Numara
          Row(
            children: [
              // Ülke Kodu Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDialCode,
                    onChanged: (val) =>
                        setState(() => _selectedDialCode = val!),
                    items: Validators.dialCodes.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['code'],
                        child: Text(
                          '${c['code']}',
                          style: GoogleFonts.outfit(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Numara alanı
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_otpSent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Sadece rakam
                  ],
                  decoration: _inputDecoration('Telefon Numarası', Icons.phone_outlined),
                  validator: (v) => Validators.validatePhone(v,
                      dialCode: _selectedDialCode),
                ),
              ),
            ],
          ),

          if (_otpSent) ...[
            const SizedBox(height: 14),

            // Geri sayım veya süre doldu uyarısı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _otpExpired
                    ? Colors.red.shade50
                    : (_secondsLeft <= 15 ? Colors.orange.shade50 : Colors.green.shade50),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _otpExpired
                      ? Colors.red.shade300
                      : (_secondsLeft <= 15 ? Colors.orange.shade300 : Colors.green.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      _otpExpired ? Icons.timer_off : Icons.timer_outlined,
                      size: 16,
                      color: _otpExpired
                          ? Colors.red.shade700
                          : (_secondsLeft <= 15 ? Colors.orange.shade700 : Colors.green.shade700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _otpExpired
                          ? 'Kodun süresi doldu'
                          : 'Kalan süre: $_secondsLeft sn',
                      style: GoogleFonts.outfit(
                        color: _otpExpired
                            ? Colors.red.shade700
                            : (_secondsLeft <= 15 ? Colors.orange.shade700 : Colors.green.shade700),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                  if (_otpExpired)
                    GestureDetector(
                      onTap: _resetOtp,
                      child: Text(
                        'Tekrar Gönder',
                        style: GoogleFonts.outfit(
                          color: _kRed,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: _kRed,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_otpExpired,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('6 Haneli SMS Kodu', Icons.sms_outlined),
            ),
            TextButton(
              onPressed: _resetOtp,
              child: Text('Farklı numara kullan',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: GoogleFonts.outfit(fontSize: 13),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }
}
