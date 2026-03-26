import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';
import 'registration_success_screen.dart';
import 'sign_in.dart';
import 'main_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  File? _profileImage; // Profil resmi dosyası

  // Form keys — her adım için ayrı
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // ─── Adım 1: Kimlik ───
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tcNoController = TextEditingController();
  String _citizenship = 'TC';
  final _passportController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'Erkek';
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  bool _phoneOtpSent = false;
  bool _phoneVerified = false;
  bool _phoneOtpExpired = false;
  String? _phoneVerificationId;
  String _selectedDialCode = '+90';

  // ─── E-posta Doğrulama Durumu ───
  bool _emailVerified = false;
  Timer? _emailPollingTimer;
  bool _emailLinkSent = false;

  // OTP geri sayım — Kayıt için 120 saniye
  Timer? _phoneTimer;
  int _phoneSecondsLeft = 120;
  static const int _phoneOtpTimeout = 120;

  // ─── Adım 2: Sağlık ───
  String _bloodType = 'A+';
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  // ─── Adım 3: Acil Kişiler ───
  final List<EmergencyContact> _emergencyContacts = [];
  final _ecNameController = TextEditingController();
  final _ecPhoneController = TextEditingController();
  String _ecRelationship = 'Anne';
  String _ecDialCode = '+90';

  // ─── Adım 4: Şifre ───
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isLoading = false;

  static const _kRed = Color(0xFFE53935);
  static const _kDarkRed = Color(0xFFB71C1C);

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'
  ];
  final List<String> _relationships = [
    'Anne', 'Baba', 'Eş', 'Kardeş', 'Çocuk', 'Diğer'
  ];

  final List<String> _stepTitles = [
    '1. Kimlik Bilgileri',
    '2. Sağlık Bilgileri',
    '3. Acil Durum Kişileri',
    '4. Güvenlik',
  ];

  @override
  void dispose() {
    _phoneTimer?.cancel();
    _emailPollingTimer?.cancel();
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tcNoController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phoneOtpController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _ecNameController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

  // ─── 120 saniyelik OTP geri sayımı ───
  void _startPhoneTimer() {
    _phoneTimer?.cancel();
    setState(() {
      _phoneSecondsLeft = _phoneOtpTimeout;
      _phoneOtpExpired = false;
    });
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _phoneSecondsLeft--);
      if (_phoneSecondsLeft <= 0) {
        t.cancel();
        setState(() => _phoneOtpExpired = true);
      }
    });
  }

  // ─── OTP sıfırla (Tekrar Gönder) ───
  void _resetPhoneOtp() {
    _phoneTimer?.cancel();
    setState(() {
      _phoneOtpSent = false;
      _phoneOtpExpired = false;
      _phoneSecondsLeft = _phoneOtpTimeout;
      _phoneOtpController.clear();
      _phoneVerificationId = null;
    });
  }

  // ─── Profil Resmi Seçme ───
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000, // Performans ve boyut için limit
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final error = Validators.validateImageFile(file);
        if (error != null) {
          _showError(error);
          return;
        }
        setState(() => _profileImage = file);
        _showToast('Fotoğraf başarıyla seçildi.');
      }
    } catch (e) {
      _showError('Fotoğraf seçilirken bir hata oluştu.');
    }
  }

  // ─── Sayfa Geçişleri ───
  void _nextPage() {
    if (!_formKeys[_currentPage].currentState!.validate()) return;

    // Adım 1 için ek kontroller
    if (_currentPage == 0) {
      if (_birthDate == null) {
        _showError('Doğum tarihinizi seçin.');
        return;
      }
      final age = _calculateAge(_birthDate!);
      if (age < 18) {
        _showError('Bu uygulamaya kayıt olmak için 18 yaşını doldurmuş olmanız gerekmektedir.');
        return;
      }
      if (!_emailVerified) {
        _showError('Lütfen devam etmeden önce e-posta adresinizi doğrulayın.');
        return;
      }
      if (!_phoneVerified) {
        _showError('Lütfen devam etmeden önce telefon numaranızı doğrulayın.');
        return;
      }
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ─── Telefon OTP ───
  Future<void> _sendPhoneOtp() async {
    final phoneError = Validators.validatePhone(
      _phoneController.text.trim(),
      dialCode: _selectedDialCode,
    );
    if (phoneError != null) { _showError(phoneError); return; }

    setState(() => _isLoading = true);
    final fullPhone = Validators.formatPhone(
        _phoneController.text.trim(), _selectedDialCode);
    final authService = ref.read(authServiceProvider);
    await authService.sendPhoneOtp(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _phoneOtpSent = true;
          _phoneVerificationId = verificationId;
        });
        _startPhoneTimer(); // ⏱ 120 saniye başlat
        _showToast('SMS kodu gönderildi! 120 saniye geçerli.');
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showError(error);
      },
    );
  }

  Future<void> _verifyPhoneOtp() async {
    // Süre dolmuşsa engelle
    if (_phoneOtpExpired) {
      _showError('Kodun süresi doldu. Lütfen tekrar kod isteyin.');
      return;
    }
    final otp = _phoneOtpController.text.trim();
    if (otp.length < 6) { _showError('6 haneli kodu eksiksiz girin.'); return; }
    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    final error = await authService.verifyPhoneOtp(
      smsCode: otp, 
      verificationId: _phoneVerificationId,
      linkInsteadOfSignIn: authService.currentUser != null, // Eğer zaten e-posta ile giriş yapılmışsa bağla
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error == null) {
      _phoneTimer?.cancel();
      setState(() => _phoneVerified = true);
      _showToast('Telefon numarası doğrulandı ✓');
    } else {
      _showError(error);
    }
  }

  // ─── E-posta Doğrulama (Link Bazlı + Polling) ───
  Future<void> _sendVerificationLink() async {
    if (_emailController.text.trim().isEmpty) {
      _showError('Lütfen önce e-posta adresinizi girin.');
      return;
    }
    // Şifre validate edilmeli
    if (_passwordController.text.isEmpty) {
      _showError('Doğrulama maili göndermek ve hesabınızı oluşturmak için lütfen bir şifre belirleyin.');
      return;
    }
    final passError = Validators.validatePassword(_passwordController.text.trim());
    if (passError != null) { _showError(passError); return; }

    // Şifre eşleşme kontrolü
    if (_passwordController.text != _passwordConfirmController.text) {
      _showError('Şifreler eşleşmiyor.');
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    
    String? error;
    if (authService.currentUser != null) {
      // Eğer zaten telefon ile giriş yapılmışsa (yani önce telefonu doğruladıysa)
      error = await authService.linkEmailWithExistingAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      // Hiç oturum yoksa yeni hesap oluştur
      error = await authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      setState(() => _emailLinkSent = true);
      _showToast('Doğrulama linki gönderildi! Lütfen mail kutunuzu kontrol edin.');
      _startEmailVerificationPolling();
    } else {
      _showError(error);
    }
  }

  void _startEmailVerificationPolling() {
    _emailPollingTimer?.cancel();
    _emailPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;
      
      if (user != null) {
        await user.reload(); // Firebase'den güncel durumu çek
        if (user.emailVerified) {
          timer.cancel();
          if (mounted) {
            setState(() => _emailVerified = true);
            _showToast('E-posta başarıyla doğrulandı! ✅');
          }
        }
      }
    });
  }

  // ─── Acil Kişi Ekle ───
  void _addEmergencyContact() {
    final nameError = Validators.validateName(
        _ecNameController.text, fieldName: 'Kişi adı soyadı');
    if (nameError != null) { _showError(nameError); return; }
    final phoneError = Validators.validatePhone(
        _ecPhoneController.text, dialCode: _ecDialCode);
    if (phoneError != null) { _showError(phoneError); return; }
    setState(() {
      _emergencyContacts.add(EmergencyContact(
        name: Validators.sanitize(_ecNameController.text),
        phone: Validators.formatPhone(
            _ecPhoneController.text.trim(), _ecDialCode),
        relationship: _ecRelationship,
      ));
      _ecNameController.clear();
      _ecPhoneController.clear();
    });
  }

  // ─── Kayıt İşlemi (Son Adım) ───
  Future<void> _register() async {
    if (!_formKeys[3].currentState!.validate()) return;
    if (_emergencyContacts.isEmpty) {
      // Adım 3'e geri don
      _showError('En az 1 acil durum kişisi eklemelisiniz.');
      _pageController.animateToPage(2,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);

    // Eğer zaten giriş yapılmışsa (e-posta adımı sırasında), tekrar register çağırmaya gerek yok
    if (authService.currentUser == null) {
      final regError = await authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      if (regError != null) {
        setState(() => _isLoading = false);
        _showError(regError);
        return;
      }
    }

    final uid = authService.currentUser!.uid;
    final userModel = UserModel(
      uid: uid,
      firstName: Validators.sanitize(_firstNameController.text),
      lastName: Validators.sanitize(_lastNameController.text),
      tcNo: Validators.sanitize(_tcNoController.text),
      citizenship: _citizenship,
      passportNo: _citizenship == 'Yabancı'
          ? Validators.sanitize(_passportController.text)
          : null,
      birthDate: _birthDate!,
      gender: _gender,
      email: _emailController.text.trim().toLowerCase(),
      phone: Validators.formatPhone(
          _phoneController.text.trim(), _selectedDialCode),
      isEmailVerified: _emailVerified,
      isPhoneVerified: _phoneVerified,
      bloodType: _bloodType,
      chronicDiseases: _chronicController.text.isEmpty
          ? null
          : Validators.sanitize(_chronicController.text),
      allergies: _allergiesController.text.isEmpty
          ? null
          : Validators.sanitize(_allergiesController.text),
      currentMedications: _medicationsController.text.isEmpty
          ? null
          : Validators.sanitize(_medicationsController.text),
      emergencyContacts: _emergencyContacts,
      createdAt: DateTime.now(),
      isProfileComplete: true,
      profilePictureUrl: _profileImage?.path,
    );

    final saveError = await authService.saveUserProfile(userModel);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (saveError != null) { _showError(saveError); return; }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
      (route) => false,
    );
  }

  void _showError(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.red.shade800,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG);

  void _showToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white);

  // ════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kRed, _kDarkRed, Color(0xFF880E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Üst Bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: _prevPage,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    Expanded(
                      child: Text(
                        _stepTitles[_currentPage],
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Adım göstergesi
                    Text(
                      '${_currentPage + 1}/4',
                      style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // ── Progress Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: Colors.white,
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Sayfa İçerikleri ──
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),

              // ── Alt Navigasyon ──
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Alt Butonlar ──
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentPage == 3 ? _register : _nextPage),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _kDarkRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kDarkRed))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == 3 ? 'KAYDI TAMAMLA' : 'DEVAM ET',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1.1),
                        ),
                        if (_currentPage < 3) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Zaten hesabın var mı? ',
                  style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const SignInScreen())),
                child: Text('Giriş Yap',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // ADIM 1: KİMLİK BİLGİLERİ
  // ════════════════════════════════════════
  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _buildCard(children: [
          // Profil Resmi Seçici
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _kRed.withValues(alpha: 0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kDarkRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Profil Fotoğrafı Seçin',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ad - Soyad
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: _deco('Ad *', Icons.person),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))
                ],
                validator: (v) => Validators.validateName(v, fieldName: 'Ad'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: _deco('Soyad *', Icons.person_outline),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))
                ],
                validator: (v) =>
                    Validators.validateName(v, fieldName: 'Soyad'),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Vatandaşlık
          DropdownButtonFormField<String>(
            value: _citizenship,
            decoration: _deco('Vatandaşlık *', Icons.flag_outlined),
            items: ['TC', 'Yabancı']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _citizenship = v!),
          ),
          const SizedBox(height: 12),

          // TC No veya Pasaport
          if (_citizenship == 'TC')
            TextFormField(
              controller: _tcNoController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _deco('T.C. Kimlik No *', Icons.credit_card),
              validator: Validators.validateTcNo,
            )
          else
            TextFormField(
              controller: _passportController,
              decoration: _deco('Pasaport No *', Icons.credit_card),
              validator: Validators.validatePassport,
            ),
          const SizedBox(height: 12),

          // Doğum Tarihi (18+ kontrolü)
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(DateTime.now().year - 20),
                firstDate: DateTime(1920),
                // En geç bugünden tam 18 yıl önce
                lastDate: DateTime(
                  DateTime.now().year - 18,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
                builder: (context, child) => Theme(
                  data: ThemeData.light().copyWith(
                      colorScheme:
                          const ColorScheme.light(primary: _kRed)),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _birthDate == null
                        ? Colors.grey.shade400
                        : _kRed),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today_outlined,
                    color:
                        _birthDate == null ? Colors.grey : _kRed, size: 20),
                const SizedBox(width: 12),
                Text(
                  _birthDate == null
                      ? 'Doğum Tarihi Seçin * (18+)'
                      : DateFormat('dd/MM/yyyy').format(_birthDate!),
                  style: GoogleFonts.outfit(
                    color: _birthDate == null ? Colors.grey : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Cinsiyet (Geri getirildi)
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: _deco('Cinsiyet *', Icons.wc_outlined),
            items: ['Erkek', 'Kadın', 'Belirtmek İstemiyorum']
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_emailVerified,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            decoration: _deco('E-posta *', Icons.email_outlined).copyWith(
              suffixIcon: _verifyBtn(
                label: _emailLinkSent ? 'Tekrar' : 'Doğrula',
                onTap: _sendVerificationLink,
                verified: _emailVerified,
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            validator: Validators.validateEmail,
          ),
          if (!_emailVerified) ...[
            const SizedBox(height: 4),
            Text(
              _emailLinkSent ? 'Onay linki gönderildi, lütfen mailinizi kontrol edin.' : 'Hesabı oluşturmak için e-postayı doğrulayın.',
              style: GoogleFonts.outfit(fontSize: 11, color: _emailLinkSent ? Colors.orange.shade800 : Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 14),

          // Şifre Gereksinimleri (Şifre alanının hemen üzerine taşındı)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ruleRow('En az 10 karakter & 1 Büyük harf'),
                _ruleRow('1 Rakam & 1 Özel karakter'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Şifre Alanları
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !_emailVerified,
            decoration: _deco('Şifre *', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _passwordConfirmController,
            obscureText: _obscureConfirm,
            enabled: !_emailVerified,
            decoration: _deco('Şifre Tekrar *', Icons.lock_reset_outlined).copyWith(
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Şifre onayı zorunludur.';
              if (v != _passwordController.text) return 'Şifreler eşleşmiyor.';
              return null;
            },
          ),
          const SizedBox(height: 14),


          // Telefon + Doğrulama (ZORUNLU)
          Row(children: [
            _dialCodePicker(
              value: _selectedDialCode,
              enabled: !_phoneVerified,
              onChanged: (v) => setState(() => _selectedDialCode = v!),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_phoneVerified,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _deco('Telefon No *', Icons.phone_outlined).copyWith(
                  suffixIcon: _verifyBtn(
                    label: _phoneOtpSent ? 'Doğrula' : 'Gönder',
                    onTap: _phoneOtpSent ? _verifyPhoneOtp : _sendPhoneOtp,
                    verified: _phoneVerified,
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                validator: (v) =>
                    Validators.validatePhone(v, dialCode: _selectedDialCode),
              ),
            ),
          ]),
          if (_phoneOtpSent && !_phoneVerified) ...[
            const SizedBox(height: 8),
            // Geri sayım veya süre doldu uyarısı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _phoneOtpExpired
                    ? Colors.red.shade50
                    : (_phoneSecondsLeft <= 30
                        ? Colors.orange.shade50
                        : Colors.green.shade50),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _phoneOtpExpired
                      ? Colors.red.shade300
                      : (_phoneSecondsLeft <= 30
                          ? Colors.orange.shade300
                          : Colors.green.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      _phoneOtpExpired ? Icons.timer_off : Icons.timer_outlined,
                      size: 16,
                      color: _phoneOtpExpired
                          ? Colors.red.shade700
                          : (_phoneSecondsLeft <= 30
                              ? Colors.orange.shade700
                              : Colors.green.shade700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _phoneOtpExpired
                          ? 'Kodun süresi doldu'
                          : 'Kalan süre: $_phoneSecondsLeft sn',
                      style: GoogleFonts.outfit(
                        color: _phoneOtpExpired
                            ? Colors.red.shade700
                            : (_phoneSecondsLeft <= 30
                                ? Colors.orange.shade700
                                : Colors.green.shade700),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                  if (_phoneOtpExpired)
                    GestureDetector(
                      onTap: _resetPhoneOtp,
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
              controller: _phoneOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !_phoneOtpExpired,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _deco('6 Haneli SMS Kodu', Icons.sms_outlined),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _resetPhoneOtp,
                icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                label: Text(
                  'Yanlış numara mı? Numarayı değiştir',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // ════════════════════════════════════════
  // ADIM 2: SAĞLIK BİLGİLERİ
  // ════════════════════════════════════════
  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _buildCard(children: [
          // Açıklama
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kan grubu zorunludur. Diğer sağlık bilgileri isteğe bağlıdır.',
                  style:
                      GoogleFonts.outfit(color: Colors.blue.shade800, fontSize: 12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Kan Grubu (ZORUNLU — Dropdown, güvenli)
          DropdownButtonFormField<String>(
            value: _bloodType,
            decoration: _deco('Kan Grubu *', Icons.water_drop_outlined),
            items: _bloodTypes
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _bloodType = v!),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Kan grubu seçimi zorunludur.' : null,
          ),
          const SizedBox(height: 14),

          // Kronik Hastalıklar (İsteğe bağlı)
          TextFormField(
            controller: _chronicController,
            maxLines: 3,
            decoration: _deco(
                'Kronik Hastalıklar (İsteğe Bağlı)',
                Icons.medical_information_outlined),
            validator: (v) =>
                Validators.validateFreeText(v, fieldName: 'Kronik hastalıklar'),
          ),
          const SizedBox(height: 12),

          // Alerjiler (İsteğe bağlı)
          TextFormField(
            controller: _allergiesController,
            maxLines: 3,
            decoration: _deco('Alerjiler - özellikle ilaç (İsteğe Bağlı)',
                Icons.warning_amber_outlined),
            validator: (v) =>
                Validators.validateFreeText(v, fieldName: 'Alerji bilgisi'),
          ),
          const SizedBox(height: 12),

          // İlaçlar (İsteğe bağlı)
          TextFormField(
            controller: _medicationsController,
            maxLines: 3,
            decoration: _deco('Sürekli Kullanılan İlaçlar (İsteğe Bağlı)',
                Icons.medication_outlined),
            validator: (v) =>
                Validators.validateFreeText(v, fieldName: 'Kullanılan ilaçlar'),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════
  // ADIM 3: ACİL DURUM KİŞİLERİ
  // ════════════════════════════════════════
  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _buildCard(children: [
          // Eklenen kişiler
          if (_emergencyContacts.isNotEmpty)
            ..._emergencyContacts.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.name} (${c.relationship})',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(c.phone,
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    onPressed: () =>
                        setState(() => _emergencyContacts.removeAt(i)),
                  ),
                ]),
              );
            }),

          // Yeni kişi formu
          TextFormField(
            controller: _ecNameController,
            decoration:
                _deco('Kişi Adı Soyadı *', Icons.person_add_outlined),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))
            ],
          ),
          const SizedBox(height: 10),

          Row(children: [
            _dialCodePicker(
              value: _ecDialCode,
              onChanged: (v) => setState(() => _ecDialCode = v!),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextFormField(
                controller: _ecPhoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _deco('Telefon No *', Icons.phone_outlined),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: _ecRelationship,
            decoration:
                _deco('Yakınlık Derecesi', Icons.family_restroom),
            items: _relationships
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _ecRelationship = v!),
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, color: _kRed),
              label: Text('Kişi Ekle',
                  style: GoogleFonts.outfit(
                      color: _kRed, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _addEmergencyContact,
            ),
          ),

          if (_emergencyContacts.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ En az 1 acil durum kişisi eklemeniz gerekmektedir.',
              style: GoogleFonts.outfit(
                  color: Colors.red.shade700, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ]),
      ),
    );
  }

  // ════════════════════════════════════════
  // ADIM 4: ŞİFRE & GÜVENLİK
  // ════════════════════════════════════════
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: _buildCard(children: [
        Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text(
                'Neredeyse Hazır!',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'E-posta ve kimlik bilgileriniz başarıyla işlendi. Kaydı tamamlamak için aşağıdaki butona basın.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.grey.shade700, fontSize: 15),
              ),
              const SizedBox(height: 32),
              if (!_emailVerified) 
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dikkat: E-posta henüz doğrulanmamış. Lütfen linke tıklayın.',
                        style: GoogleFonts.outfit(color: Colors.red.shade900, fontSize: 12),
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════
  // YARDIMCI WİDGET'LAR
  // ════════════════════════════════════════
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _dialCodePicker({
    required String value,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: enabled ? onChanged : null,
          items: Validators.dialCodes.map((c) => DropdownMenuItem<String>(
                value: c['code'],
                child: Text(c['code']!,
                    style: GoogleFonts.outfit(fontSize: 13)),
              )).toList(),
        ),
      ),
    );
  }

  Widget _verifyBtn({
    required String label,
    required VoidCallback? onTap,
    required bool verified,
  }) {
    return GestureDetector(
      onTap: verified ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        width: 80, // Sabit genişlik ki zıplamasın
        decoration: BoxDecoration(
          color: verified ? Colors.green : _kRed,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(11),
            bottomRight: Radius.circular(11),
          ),
        ),
        child: Center(
          child: verified
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(label,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
        ),
      ),
    );
  }

  Widget _ruleRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(Icons.check_circle_outline,
            size: 14, color: Colors.amber.shade700),
        const SizedBox(width: 6),
        Text(text,
            style: GoogleFonts.outfit(
                color: Colors.amber.shade900, fontSize: 12)),
      ]),
    );
  }

  InputDecoration _deco(String label, IconData icon) {
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: GoogleFonts.outfit(fontSize: 13),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    );
  }
}
