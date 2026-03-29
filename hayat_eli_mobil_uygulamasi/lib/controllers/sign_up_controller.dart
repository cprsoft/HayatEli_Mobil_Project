import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';

// ─── State Sınıfı ───
class SignUpState {
  final bool isLoading;
  final String? errorMessage;
  
  // Telefon Doğrulama Durumları
  final bool isPhoneOtpSent;
  final bool isPhoneVerified;
  final bool isPhoneOtpExpired;
  final int phoneSecondsLeft;
  
  // E-Posta Doğrulama Durumları
  final bool isEmailLinkSent;
  final bool isEmailVerified;
  final bool isEmailLinkExpired;
  final int emailSecondsLeft;

  // Acil Durum Kişileri
  final List<EmergencyContact> emergencyContacts;

  SignUpState({
    this.isLoading = false,
    this.errorMessage,
    this.isPhoneOtpSent = false,
    this.isPhoneVerified = false,
    this.isPhoneOtpExpired = false,
    this.phoneSecondsLeft = 120,
    this.isEmailLinkSent = false,
    this.isEmailVerified = false,
    this.isEmailLinkExpired = false,
    this.emailSecondsLeft = 120,
    this.emergencyContacts = const [],
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isPhoneOtpSent,
    bool? isPhoneVerified,
    bool? isPhoneOtpExpired,
    int? phoneSecondsLeft,
    bool? isEmailLinkSent,
    bool? isEmailVerified,
    bool? isEmailLinkExpired,
    int? emailSecondsLeft,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPhoneOtpSent: isPhoneOtpSent ?? this.isPhoneOtpSent,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isPhoneOtpExpired: isPhoneOtpExpired ?? this.isPhoneOtpExpired,
      phoneSecondsLeft: phoneSecondsLeft ?? this.phoneSecondsLeft,
      isEmailLinkSent: isEmailLinkSent ?? this.isEmailLinkSent,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isEmailLinkExpired: isEmailLinkExpired ?? this.isEmailLinkExpired,
      emailSecondsLeft: emailSecondsLeft ?? this.emailSecondsLeft,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
}

// ─── Provider ───
final signUpControllerProvider = NotifierProvider<SignUpController, SignUpState>(() {
  return SignUpController();
});

// ─── Controller ───
class SignUpController extends Notifier<SignUpState> {
  late AuthService authService;
  Timer? _phoneTimer;
  Timer? _emailPollingTimer;
  Timer? _emailTimer;
  String? _verificationId;

  @override
  SignUpState build() {
    authService = ref.read(authServiceProvider);
    ref.onDispose(() {
      _phoneTimer?.cancel();
      _emailPollingTimer?.cancel();
      _emailTimer?.cancel();
    });
    return SignUpState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ==========================================
  // TELEFON BİLGİLERİ (OTP GÖNDERME & DOĞRULAMA)
  // ==========================================

  Future<bool> sendPhoneOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // Siber Güvenlik Kontrolü: Bu numaranın zaten sistemde kayıtlı olup olmadığını denetle
    try {
      final querySnapshot = await authService.firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        state = state.copyWith(
          isLoading: false, 
          errorMessage: 'Güvenlik Uyarısı: Bu telefon numarası başka bir hesap tarafından kullanılıyor.'
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Veritabanı bağlantı hatası.');
      return false;
    }

    final error = await authService.sendPhoneOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        state = state.copyWith(
          isLoading: false, 
          isPhoneOtpSent: true, 
          phoneSecondsLeft: 120, 
          isPhoneOtpExpired: false
        );
        _startPhoneTimer();
      },
      onError: (err) {
        state = state.copyWith(isLoading: false, errorMessage: err);
      },
    );

    if (error != null) {
      state = state.copyWith(isLoading: false, errorMessage: error);
      return false;
    }
    return true; 
  }

  Future<bool> verifyPhoneOtp(String smsCode) async {
    if (state.isPhoneOtpExpired) {
      state = state.copyWith(errorMessage: 'Kodun süresi doldu. Lütfen yeni kod isteyin.');
      return false;
    }
    if (smsCode.length < 6) {
      state = state.copyWith(errorMessage: '6 haneli kodu eksiksiz girin.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final error = await authService.verifyPhoneOtp(
      smsCode: smsCode,
      verificationId: _verificationId,
      linkInsteadOfSignIn: authService.currentUser != null,
    );

    if (error == null) {
      _phoneTimer?.cancel();
      state = state.copyWith(isLoading: false, isPhoneVerified: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: error);
      return false;
    }
  }

  void _startPhoneTimer() {
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.phoneSecondsLeft > 0) {
        state = state.copyWith(phoneSecondsLeft: state.phoneSecondsLeft - 1);
      } else {
        state = state.copyWith(isPhoneOtpExpired: true);
        timer.cancel();
      }
    });
  }

  void resetPhoneOtpState() {
    _phoneTimer?.cancel();
    state = state.copyWith(
      isPhoneOtpSent: false, 
      isPhoneOtpExpired: false, 
      phoneSecondsLeft: 120, 
      clearError: true
    );
    _verificationId = null;
  }

  // ==========================================
  // E-POSTA DOĞRULAMA (6 HANELİ KOD)
  // ==========================================

  Future<bool> sendEmailOtp({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final error = await authService.sendEmailOtp(email: email);
    
    if (error == null) {
      state = state.copyWith(
        isLoading: false, 
        isEmailLinkSent: true,
        isEmailLinkExpired: false,
        emailSecondsLeft: 120,
      );
      _startEmailTimer();
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: error);
      return false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String code) async {
    if (state.isEmailLinkExpired) {
      state = state.copyWith(errorMessage: 'Kodun süresi doldu. Lütfen tekrar gönderin.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final success = await authService.verifyEmailOtp(email: email, code: code);
    
    state = state.copyWith(isLoading: false);
    if (success) {
      state = state.copyWith(isEmailVerified: true);
      _emailTimer?.cancel();
      return true;
    } else {
      state = state.copyWith(errorMessage: 'Girdiğiniz kod hatalı veya süresi dolmuş.');
      return false;
    }
  }

  void _startEmailTimer() {
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.emailSecondsLeft > 0) {
        state = state.copyWith(emailSecondsLeft: state.emailSecondsLeft - 1);
      } else {
        state = state.copyWith(isEmailLinkExpired: true);
        timer.cancel();
      }
    });
  }

  void resetEmailState() {
    _emailTimer?.cancel();
    state = state.copyWith(
      isEmailLinkSent: false,
      isEmailLinkExpired: false,
      isEmailVerified: false,
      emailSecondsLeft: 120,
      clearError: true,
    );
  }

  // ==========================================
  // ACİL DURUM KİŞİLERİ YÖNETİMİ
  // ==========================================

  void addEmergencyContact(EmergencyContact contact) {
    if (state.emergencyContacts.length >= 5) {
      state = state.copyWith(errorMessage: 'En fazla 5 acil durum kişisi ekleyebilirsiniz.');
      return;
    }
    state = state.copyWith(
      clearError: true,
      emergencyContacts: [...state.emergencyContacts, contact],
    );
  }

  void removeEmergencyContact(int index) {
    final updatedList = List<EmergencyContact>.from(state.emergencyContacts);
    updatedList.removeAt(index);
    state = state.copyWith(emergencyContacts: updatedList);
  }

  // ==========================================
  // KAYIT İŞLEMİ (SON ADIM - GERÇEK KAYIT BURADA)
  // ==========================================

  Future<bool> registerUser(UserModel userModel, {required String password, File? profileImage}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    // 1. ÖNCE FIREBASE AUTH KAYDINI YAP
    final authError = await authService.registerWithEmail(
      email: userModel.email,
      password: password,
    );

    if (authError != null) {
      state = state.copyWith(isLoading: false, errorMessage: authError);
      return false;
    }

    // 2. KAYIT BAŞARILIYSA UID'Yİ AL
    final realUid = authService.currentUser?.uid;
    if (realUid == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'Kullanıcı oluşturuldu ama oturum açılamadı.');
      return false;
    }

    // 3. PROFİL BİLGİLERİNİ HAZIRLA
    final sanitizedUser = UserModel(
      uid: realUid,
      firstName: Validators.sanitize(userModel.firstName),
      lastName: Validators.sanitize(userModel.lastName),
      tcNo: Validators.sanitize(userModel.tcNo),
      citizenship: userModel.citizenship,
      passportNo: userModel.passportNo,
      birthDate: userModel.birthDate,
      gender: userModel.gender,
      email: userModel.email,
      phone: userModel.phone,
      isEmailVerified: true,
      isPhoneVerified: userModel.isPhoneVerified,
      bloodType: userModel.bloodType,
      chronicDiseases: userModel.chronicDiseases,
      allergies: userModel.allergies,
      currentMedications: userModel.currentMedications,
      emergencyContacts: userModel.emergencyContacts,
      createdAt: userModel.createdAt,
      isProfileComplete: true,
      profilePictureUrl: userModel.profilePictureUrl,
    );

    // 4. FOTOĞRAF VARSA YÜKLE
    String? photoUrl;
    if (profileImage != null) {
      photoUrl = await authService.uploadProfileImage(
        uid: realUid,
        imageFile: profileImage,
      );
    }

    // 5. FIRESTORE'A KAYDET
    final finalUser = sanitizedUser.copyWith(profilePictureUrl: photoUrl);
    final firestoreError = await authService.saveUserProfile(finalUser);
    
    state = state.copyWith(isLoading: false);

    if (firestoreError != null) {
      state = state.copyWith(errorMessage: firestoreError);
      return false;
    }
    return true;
  }
}
