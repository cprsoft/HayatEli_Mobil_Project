import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../controllers/sign_up_controller.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';
import 'registration_success_screen.dart';
import 'sign_in.dart';

import '../widgets/auth/sign_up/identity_step.dart';
import '../widgets/auth/sign_up/health_step.dart';
import '../widgets/auth/sign_up/emergency_step.dart';
import '../widgets/auth/sign_up/security_step.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  File? _profileImage;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _tcNoController = TextEditingController();
  final _passportController = TextEditingController();
  String _citizenship = 'TC';
  DateTime? _birthDate;
  String _gender = 'Erkek';
  final _emailController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  String _selectedDialCode = '+90';

  String? _bloodType;
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  final _ecNameController = TextEditingController();
  final _ecPhoneController = TextEditingController();
  String? _ecRelationship;
  String _ecDialCode = '+90';

  static const _kDarkRed = Color(0xFFB71C1C);

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _tcNoController.dispose();
    _passportController.dispose();
    _emailController.dispose();
    _emailOtpController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _phoneOtpController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _ecNameController.dispose();
    _ecPhoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.red, textColor: Colors.white);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(msg: message, backgroundColor: Colors.green, textColor: Colors.white);
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000, imageQuality: 85);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Profil Fotoğrafını Kırp',
              toolbarColor: _kDarkRed,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Profil Fotoğrafını Kırp',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          final file = File(croppedFile.path);
          final error = Validators.validateImageFile(file);
          if (error != null) {
            _showError(error);
            return;
          }
          setState(() => _profileImage = file);
          _showToast('Fotoğraf başarıyla kırpıldı ve seçildi.');
        }
      }
    } catch (e) {
      _showError('Fotoğraf seçilirken bir hata oluştu.');
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
    return age;
  }

  void _nextPage() {
    final authState = ref.read(signUpControllerProvider);

    if (!_formKeys[_currentPage].currentState!.validate()) return;

    if (_currentPage == 0) {
      if (_birthDate == null) {
        _showError('Doğum tarihinizi seçin.');
        return;
      }
      if (_calculateAge(_birthDate!) < 18) {
        _showError('Bu uygulamaya kayıt olmak için 18 yaşını doldurmuş olmanız gerekmektedir.');
        return;
      }
      if (!authState.isEmailVerified) {
        _showError('Lütfen devam etmeden önce e-posta adresinizi doğrulayın.');
        return;
      }
      if (!authState.isPhoneVerified) {
        _showError('Lütfen devam etmeden önce telefon numaranızı doğrulayın.');
        return;
      }
    }

    if (_currentPage == 2) {
      if (authState.emergencyContacts.isEmpty) {
        _showError('Lütfen devam etmek için en az 1 acil durum kişisi ekleyin.');
        return;
      }
    }

    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _register() async {
    final authState = ref.read(signUpControllerProvider);
    final authNotifier = ref.read(signUpControllerProvider.notifier);
    if (!authState.isEmailVerified || !authState.isPhoneVerified) {
      _showError('Güvenlik ihlali: E-posta veya telefon numarası doğrulanmamış işlemler devam edemez.');
      return;
    }

    final newUser = UserModel(
      uid: '', 
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: Validators.formatPhone(_phoneController.text.trim(), _selectedDialCode),
      tcNo: _citizenship == 'TC' ? _tcNoController.text.trim() : '',
      citizenship: _citizenship,
      passportNo: _citizenship == 'Yabancı' ? _passportController.text.trim() : null,
      bloodType: _bloodType ?? '',
      birthDate: _birthDate!,
      gender: _gender,
      chronicDiseases: _chronicController.text.trim(),
      allergies: _allergiesController.text.trim(),
      currentMedications: _medicationsController.text.trim(),
      emergencyContacts: authState.emergencyContacts,
      createdAt: DateTime.now(),
      isProfileComplete: true,
      profilePictureUrl: null,
    );

    final success = await authNotifier.registerUser(newUser, password: _passwordController.text, profileImage: _profileImage);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(signUpControllerProvider);
    final authNotifier = ref.read(signUpControllerProvider.notifier);

    ref.listen<SignUpState>(signUpControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        _showError(next.errorMessage!);
        authNotifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB71C1C),
              Color(0xFFE53935),
              Color(0xFFC62828),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _prevPage();
                        } else {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                        }
                      },
                    ),
                    Expanded(
                      child: Text('HAYAT ELİ',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text('${_currentPage + 1}/4', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    IdentityStep(
                      formKey: _formKeys[0],
                      profileImage: _profileImage,
                      onPickImage: _pickImage,
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      tcNoController: _tcNoController,
                      passportController: _passportController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      passwordConfirmController: _passwordConfirmController,
                      phoneController: _phoneController,
                      phoneOtpController: _phoneOtpController,
                      emailOtpController: _emailOtpController,
                      citizenship: _citizenship,
                      onCitizenshipChanged: (v) => setState(() => _citizenship = v!),
                      birthDate: _birthDate,
                      onBirthDateChanged: (v) => setState(() => _birthDate = v),
                      gender: _gender,
                      onGenderChanged: (v) => setState(() => _gender = v!),
                      selectedDialCode: _selectedDialCode,
                      onDialCodeChanged: (v) => setState(() => _selectedDialCode = v!),
                      emailLinkSent: authState.isEmailLinkSent,
                      emailVerified: authState.isEmailVerified,
                      isEmailLinkExpired: authState.isEmailLinkExpired,
                      emailSecondsLeft: authState.emailSecondsLeft,
                      phoneOtpSent: authState.isPhoneOtpSent,
                      phoneVerified: authState.isPhoneVerified,
                      phoneOtpExpired: authState.isPhoneOtpExpired,
                      phoneSecondsLeft: authState.phoneSecondsLeft,
                      onSendVerificationLink: () {
                        final email = _emailController.text.trim();
                        final pass = _passwordController.text;
                        final passConfirm = _passwordConfirmController.text;
                        
                        if (email.isEmpty) { _showError('Lütfen e-posta girin.'); return; }
                        if (pass.isEmpty) { _showError('Lütfen şifre belirleyin.'); return; }
                        if (pass != passConfirm) { _showError('Şifreler eşleşmiyor.'); return; }
                        
                        authNotifier.sendEmailOtp(email: email);
                      },
                      onVerifyEmailOtp: () {
                         authNotifier.verifyEmailOtp(_emailController.text.trim(), _emailOtpController.text.trim());
                      },
                      onResetEmailState: authNotifier.resetEmailState,
                      onSendPhoneOtp: () {
                        final fullPhone = Validators.formatPhone(_phoneController.text.trim(), _selectedDialCode);
                        authNotifier.sendPhoneOtp(fullPhone);
                      },
                      onVerifyPhoneOtp: () => authNotifier.verifyPhoneOtp(_phoneOtpController.text.trim()),
                      onResetPhoneOtp: authNotifier.resetPhoneOtpState,
                    ),

                    HealthStep(
                      formKey: _formKeys[1],
                      bloodType: _bloodType,
                      onBloodTypeChanged: (v) => setState(() => _bloodType = v!),
                      chronicController: _chronicController,
                      allergiesController: _allergiesController,
                      medicationsController: _medicationsController,
                    ),

                    EmergencyStep(
                      formKey: _formKeys[2],
                      emergencyContacts: authState.emergencyContacts,
                      onRemoveContact: authNotifier.removeEmergencyContact,
                      ecNameController: _ecNameController,
                      ecPhoneController: _ecPhoneController,
                      ecDialCode: _ecDialCode,
                      onEcDialCodeChanged: (v) => setState(() => _ecDialCode = v!),
                      ecRelationship: _ecRelationship,
                      onEcRelationshipChanged: (v) => setState(() => _ecRelationship = v),
                      onAddContact: () {
                        if (!_formKeys[2].currentState!.validate()) return;
                        final c = EmergencyContact(
                          name: _ecNameController.text.trim(),
                          phone: Validators.formatPhone(_ecPhoneController.text.trim(), _ecDialCode),
                          relationship: _ecRelationship ?? 'Bilinmiyor',
                        );
                        authNotifier.addEmergencyContact(c);
                        _ecNameController.clear();
                        _ecPhoneController.clear();
                      },
                    ),

                    SecurityStep(emailVerified: authState.isEmailVerified),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : (_currentPage == 3 ? _register : _nextPage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _kDarkRed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: _kDarkRed))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_currentPage == 3 ? 'KAYDI TAMAMLA' : 'DEVAM ET',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.1)),
                                  if (_currentPage < 3) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward_ios, size: 16)],
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Zaten hesabın var mı? ', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Giriş Yap',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, decoration: TextDecoration.underline, decorationColor: Colors.white)),
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
      ),
    );
  }
}
