import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? message;
  final bool isError;
  final bool isSuccess;

  ForgotPasswordState({
    this.isLoading = false,
    this.message,
    this.isError = false,
    this.isSuccess = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? message,
    bool clearMessage = false,
    bool? isError,
    bool? isSuccess,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final forgotPasswordControllerProvider = NotifierProvider<ForgotPasswordController, ForgotPasswordState>(() {
  return ForgotPasswordController();
});

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  AuthService get authService => ref.read(authServiceProvider);
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @override
  ForgotPasswordState build() {
    return ForgotPasswordState();
  }

  Future<void> sendPasswordReset(String email) async {
    // 1. E-posta boş mu kontrolü
    if (email.isEmpty) {
      state = state.copyWith(message: "Lütfen bir e-posta adresi giriniz.", isError: true, isSuccess: false);
      return;
    }
    
    // 2. Format kontrolü (Kötü niyetli string/payload koruması)
    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(email)) {
      state = state.copyWith(message: "Lütfen geçerli bir e-posta adresi formatı giriniz.", isError: true, isSuccess: false);
      return;
    }

    state = state.copyWith(isLoading: true, clearMessage: true, isSuccess: false);

    try {
      // 3. Firestore sorgusu: Kullanıcı veritabanında var mı?
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          message: "Böyle bir e-posta adresi sistemde kayıtlı değil.",
          isError: true,
          isSuccess: false,
        );
        return;
      }

      // 4. Veritabanında varsa şifre sıfırlama linkini gönder
      final error = await authService.sendPasswordReset(email: email);

      if (error == null) {
        state = state.copyWith(
          isLoading: false,
          message: "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin.",
          isError: false,
          isSuccess: true,
        );
      } else {
        state = state.copyWith(isLoading: false, message: error, isError: true, isSuccess: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Beklenmeyen bir hata oluştu: $e',
        isError: true,
        isSuccess: false,
      );
    }
  }
}
