import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final UserModel? originalUser;
  final UserModel? editedUser;

  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool showEmailVerificationDialog;
  final bool showPhoneVerificationDialog;
  final int emailSecondsLeft;
  final int phoneSecondsLeft;

  ProfileState({
    this.isLoading = false,
    this.error,
    this.originalUser,
    this.editedUser,
    this.isEmailVerified = true,
    this.isPhoneVerified = true,
    this.showEmailVerificationDialog = false,
    this.showPhoneVerificationDialog = false,
    this.emailSecondsLeft = 0,
    this.phoneSecondsLeft = 0,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    UserModel? originalUser,
    UserModel? editedUser,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? showEmailVerificationDialog,
    bool? showPhoneVerificationDialog,
    int? emailSecondsLeft,
    int? phoneSecondsLeft,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      originalUser: originalUser ?? this.originalUser,
      editedUser: editedUser ?? this.editedUser,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      showEmailVerificationDialog: showEmailVerificationDialog ?? this.showEmailVerificationDialog,
      showPhoneVerificationDialog: showPhoneVerificationDialog ?? this.showPhoneVerificationDialog,
      emailSecondsLeft: emailSecondsLeft ?? this.emailSecondsLeft,
      phoneSecondsLeft: phoneSecondsLeft ?? this.phoneSecondsLeft,
    );
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(() {
  return ProfileController();
});

class ProfileController extends Notifier<ProfileState> {
  Timer? _emailTimer;
  Timer? _phoneTimer;
  String? _verificationId;

  AuthService get _authService => ref.read(authServiceProvider);

  @override
  ProfileState build() {
    final userProfile = ref.watch(userProfileProvider).value;
    
    ref.onDispose(() {
      _emailTimer?.cancel();
      _phoneTimer?.cancel();
    });

    return ProfileState(
      originalUser: userProfile,
      editedUser: userProfile,
    );
  }

  void updateField({
    String? email,
    String? phone,
    String? chronicDiseases,
    String? allergies,
    String? currentMedications,
  }) {
    if (state.editedUser == null) return;

    var updatedUser = state.editedUser!.copyWith(
      email: email,
      phone: phone,
      chronicDiseases: chronicDiseases,
      allergies: allergies,
      currentMedications: currentMedications,
    );

    bool emailChanged = email != null && email != state.originalUser?.email;
    bool phoneChanged = phone != null && phone != state.originalUser?.phone;

    state = state.copyWith(
      editedUser: updatedUser,
      isEmailVerified: !emailChanged,
      isPhoneVerified: !phoneChanged,
      clearError: true,
    );
  }

  Future<void> sendEmailOtp() async {
    final email = state.editedUser?.email;
    final validationError = Validators.validateEmail(email);
    
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Benzersizlik Kontrolü
    final usageError = await _authService.checkEmailOrPhoneUsage(
      email: email!,
      phone: null,
      excludeUid: state.originalUser!.uid,
    );

    if (usageError != null) {
      state = state.copyWith(isLoading: false, error: usageError);
      return;
    }

    final error = await _authService.sendEmailOtp(email: email);
    
    if (error == null) {
      state = state.copyWith(
        isLoading: false,
        showEmailVerificationDialog: true,
        emailSecondsLeft: 60,
      );
      _startEmailTimer();
    } else {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<bool> verifyEmailOtp(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await _authService.verifyEmailOtp(
      email: state.editedUser!.email,
      code: code,
    );

    if (success) {
      state = state.copyWith(
        isLoading: false,
        isEmailVerified: true,
        showEmailVerificationDialog: false,
      );
      _emailTimer?.cancel();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Hatalı kod.');
      return false;
    }
  }

  void _startEmailTimer() {
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.emailSecondsLeft > 0) {
        state = state.copyWith(emailSecondsLeft: state.emailSecondsLeft - 1);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> sendPhoneOtp() async {
    final phone = state.editedUser?.phone;
    // Alan kodu ayrımı gerekebilir ama EditProfileScreen direkt dialCode ile gönderiyor
    final validationError = Validators.validatePhone(phone?.replaceAll(RegExp(r'^\+\d+'), ''));
    
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Benzersizlik Kontrolü
    final usageError = await _authService.checkEmailOrPhoneUsage(
      email: null,
      phone: phone!,
      excludeUid: state.originalUser!.uid,
    );

    if (usageError != null) {
      state = state.copyWith(isLoading: false, error: usageError);
      return;
    }

    final error = await _authService.sendPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (vId) {
        _verificationId = vId;
        state = state.copyWith(
          isLoading: false,
          showPhoneVerificationDialog: true,
          phoneSecondsLeft: 60,
        );
        _startPhoneTimer();
      },
      onError: (err) {
        state = state.copyWith(isLoading: false, error: err);
      },
    );

    if (error != null) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<bool> verifyPhoneOtp(String smsCode) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    final error = await _authService.updateAuthPhone(credential);

    if (error == null) {
      state = state.copyWith(
        isLoading: false,
        isPhoneVerified: true,
        showPhoneVerificationDialog: false,
      );
      _phoneTimer?.cancel();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }

  void _startPhoneTimer() {
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.phoneSecondsLeft > 0) {
        state = state.copyWith(phoneSecondsLeft: state.phoneSecondsLeft - 1);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> uploadProfilePicture(File file) async {
    final validationError = Validators.validateImageFile(file);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final url = await _authService.uploadProfileImage(
      uid: state.originalUser!.uid,
      imageFile: file,
    );

    if (url != null) {
      state = state.copyWith(
        isLoading: false,
        editedUser: state.editedUser?.copyWith(profilePictureUrl: url),
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'Fotoğraf yüklenemedi.');
    }
  }

  Future<String?> uploadContactPicture(File file, String contactName) async {
    final validationError = Validators.validateImageFile(file);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final url = await _authService.uploadProfileImage(
        uid: '${state.originalUser!.uid}/contacts/$contactName',
        imageFile: file,
      );
      state = state.copyWith(isLoading: false);
      return url;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Kişi fotoğrafı yüklenemedi.');
      return null;
    }
  }

  void addEmergencyContact(EmergencyContact contact) {
    if (state.editedUser == null) return;
    
    final nameError = Validators.validateName(contact.name, fieldName: 'İsim');
    final phoneError = Validators.validatePhone(contact.phone.replaceAll(RegExp(r'^\+\d+'), ''));
    
    if (nameError != null || phoneError != null) {
      state = state.copyWith(error: nameError ?? phoneError);
      return;
    }

    final contacts = [...state.editedUser!.emergencyContacts, contact];
    state = state.copyWith(
      editedUser: state.editedUser!.copyWith(emergencyContacts: contacts),
      clearError: true,
    );
  }

  void addEmergencyContactAt(int index, EmergencyContact contact) {
    if (state.editedUser == null) return;
    final contacts = List<EmergencyContact>.from(state.editedUser!.emergencyContacts);
    contacts.insert(index, contact);
    state = state.copyWith(editedUser: state.editedUser!.copyWith(emergencyContacts: contacts));
  }

  void removeEmergencyContact(int index) {
    if (state.editedUser == null) return;
    final contacts = List<EmergencyContact>.from(state.editedUser!.emergencyContacts);
    contacts.removeAt(index);
    state = state.copyWith(editedUser: state.editedUser!.copyWith(emergencyContacts: contacts));
  }

  Future<bool> saveProfile({String? password}) async {
    if (state.editedUser == null) return false;

    final emailChanged = state.editedUser!.email != state.originalUser?.email;
    final phoneChanged = state.editedUser!.phone != state.originalUser?.phone;

    // Email veya telefon değiştiyse mutlaka şifre doğrulama ve OTP doğrulaması gerek
    if (emailChanged || phoneChanged) {
      if (password == null) {
        state = state.copyWith(error: 'Güvenlik için lütfen şifrenizi girin.');
        return false;
      }
      if (!state.isEmailVerified || !state.isPhoneVerified) {
        state = state.copyWith(error: 'Lütfen değişen iletişim bilgilerini doğrulayın.');
        return false;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    if (emailChanged || phoneChanged) {
      final reauthError = await _authService.reauthenticate(password!);
      if (reauthError != null) {
        state = state.copyWith(isLoading: false, error: reauthError);
        return false;
      }
    }

    if (emailChanged || phoneChanged) {
      final usageError = await _authService.checkEmailOrPhoneUsage(
        email: emailChanged ? state.editedUser!.email : null,
        phone: phoneChanged ? state.editedUser!.phone : null,
        excludeUid: state.originalUser!.uid,
      );

      if (usageError != null) {
        state = state.copyWith(isLoading: false, error: usageError);
        return false;
      }
    }
    
    final sanitizedUser = state.editedUser!.copyWith(
      firstName: Validators.sanitize(state.editedUser!.firstName),
      lastName: Validators.sanitize(state.editedUser!.lastName),
      chronicDiseases: state.editedUser!.chronicDiseases != null 
          ? Validators.sanitize(state.editedUser!.chronicDiseases!) : null,
      allergies: state.editedUser!.allergies != null 
          ? Validators.sanitize(state.editedUser!.allergies!) : null,
      currentMedications: state.editedUser!.currentMedications != null 
          ? Validators.sanitize(state.editedUser!.currentMedications!) : null,
    );

    final error = await _authService.saveUserProfile(sanitizedUser);
    
    if (error == null) {
      // Telefon zaten verifyPhoneOtp aşamasında Auth'a bağlandığı için burada tekrar yapmıyoruz.
      if (emailChanged) {
        final authError = await _authService.updateAuthEmail(sanitizedUser.email);
        if (authError != null) {
          // Firestore güncellendi ama Auth güncelleme (verification link) hatası
          // Kullanıcıyı bilgilendiriyoruz ama Firestore kaydı geçerli kalıyor.
          state = state.copyWith(isLoading: false, error: 'Profil kaydedildi fakat giriş e-postası güncellenirken bir sorun oluştu: $authError');
          return true; // Kısmi başarı
        }
      }

      state = state.copyWith(isLoading: false, originalUser: sanitizedUser);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }
}