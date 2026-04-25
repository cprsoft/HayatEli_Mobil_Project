import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/email_service.dart';

class SignInState {
  final bool isLoading;
  final String? errorMessage;
  
  final bool isPhoneOtpSent;
  final bool isPhoneOtpExpired;
  final int phoneSecondsLeft;

  SignInState({
    this.isLoading = false,
    this.errorMessage,
    this.isPhoneOtpSent = false,
    this.isPhoneOtpExpired = false,
    this.phoneSecondsLeft = 60,
  });

  SignInState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isPhoneOtpSent,
    bool? isPhoneOtpExpired,
    int? phoneSecondsLeft,
  }) {
    return SignInState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPhoneOtpSent: isPhoneOtpSent ?? this.isPhoneOtpSent,
      isPhoneOtpExpired: isPhoneOtpExpired ?? this.isPhoneOtpExpired,
      phoneSecondsLeft: phoneSecondsLeft ?? this.phoneSecondsLeft,
    );
  }
}

final signInControllerProvider = NotifierProvider<SignInController, SignInState>(() {
  return SignInController();
});

class SignInController extends Notifier<SignInState> {
  Timer? _emailTimer;
  Timer? _phoneTimer;
  String? _generatedEmailOtp;
  String? _verificationId;

  AuthService get authService => ref.read(authServiceProvider);
  EmailService get emailService => ref.read(emailServiceProvider);

  @override
  SignInState build() {
    ref.onDispose(() {
      _emailTimer?.cancel();
      _phoneTimer?.cancel();
    });
    return SignInState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }


  Future<bool> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final error = await authService.signInWithEmail(email: email, password: password);
    
    if (error == null) {
      state = state.copyWith(isLoading: false);
      return true; // Başarılı, Home'a gidecek
    } else {
      state = state.copyWith(isLoading: false, errorMessage: error);
      return false;
    }
  }

  void resetEmailOtpState() {
    _emailTimer?.cancel();
    state = state.copyWith(clearError: true);
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    await authService.signInWithEmail(email: email, password: password);
    final user = authService.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      await authService.signOut();
    }
  }


  Future<bool> sendPhoneOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final querySnapshot = await authService.firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        state = state.copyWith(
            isLoading: false, 
            errorMessage: 'Bu telefon numarasına ait bir hesap bulunamadı.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, 
          errorMessage: 'Bağlantı hatası: Sunucu kontrolü yapılamadı.');
      return false;
    }

    final error = await authService.sendPhoneOtp(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        state = state.copyWith(isLoading: false, isPhoneOtpSent: true, phoneSecondsLeft: 60, isPhoneOtpExpired: false);
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
    return true; // İşlem başlatıldı, onCodeSent bekleniyor
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
    );

    state = state.copyWith(isLoading: false);
    if (error == null) {
      _phoneTimer?.cancel();
      return true;
    } else {
      state = state.copyWith(errorMessage: error);
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
    state = state.copyWith(isPhoneOtpSent: false, isPhoneOtpExpired: false, phoneSecondsLeft: 60, clearError: true);
    _verificationId = null;
  }
}
