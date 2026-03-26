import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// ============================================================
// RIVERPOD PROVIDERS
// Uygulamanın her yerinden Firebase oturum durumunu dinlemek için
// ============================================================

/// Firebase oturum akışı - null ise misafir, dolu ise kayıtlı kullanıcı
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// AuthService'e ulaşmak için global provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

/// Giriş yapmış kullanıcının Firestore profilini dinleyen provider
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromMap(doc.data()!);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ============================================================
// AUTH SERVICE
// Firebase ile konuşan tek servis dosyası
// ============================================================

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  // Telefon doğrulama için geçici saklamalar
  String? _verificationId;

  AuthService({required this.auth, required this.firestore});

  // ────────────────────────────────────────
  // 1. E-POSTA İLE KAYIT
  // ────────────────────────────────────────
  Future<String?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Kayıt başarılı: E-posta doğrulama linki gönder
      await credential.user?.sendEmailVerification();
      return null; // Başarılı
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Hesap zaten varsa, sadece giriş yapıp maili tekrar tetiklemeyi deneyelim
        try {
          final cred = await auth.signInWithEmailAndPassword(email: email, password: password);
          if (!cred.user!.emailVerified) {
            await cred.user?.sendEmailVerification();
            return null; // Mevcut hesap ama doğrulanmamışsa maili yolladık
          }
          return 'Bu e-posta adresi zaten doğrulanmış ve kullanımda.';
        } catch (signInErr) {
          return 'Bu e-posta adresi kullanımda. Eğer sizinse lütfen giriş yapın veya şifrenizi sıfırlayın.';
        }
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  // ────────────────────────────────────────
  // 2. E-POSTA İLE GİRİŞ
  // ────────────────────────────────────────
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      // E-posta doğrulanması kontrolu
      if (credential.user != null && !credential.user!.emailVerified) {
        // Doğrulanmamış kullanıcıyı içeri sokma, çıkış yaptır
        await auth.signOut();
        return 'E-posta adresiniz henüz doğrulanmamış.\n'
            'Lütfen e-posta kutunuzu kontrol edin ve doğrulama linkine tıklayın.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Beklenmeyen bir hata oluştu: \$e';
    }
  }

  // ────────────────────────────────────────
  // 3. TELEFON İLE OTP GÖNDERME
  // ────────────────────────────────────────
  Future<String?> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber, // Örn: "+905551234567"
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android'de otomatik doğrulama
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleAuthError(e) ?? 'Doğrulama başarısız');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return null;
    } catch (e) {
      return 'SMS gönderilemedi: $e';
    }
  }

  // ────────────────────────────────────────
  // 4. TELEFON OTP DOĞRULAMA (VE BAĞLAMA)
  // ────────────────────────────────────────
  Future<String?> verifyPhoneOtp({
    required String smsCode,
    String? verificationId,
    bool linkInsteadOfSignIn = false,
  }) async {
    try {
      final vId = verificationId ?? _verificationId;
      if (vId == null) return 'Doğrulama oturumu zaman aşımına uğradı.';

      final credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: smsCode,
      );

      if (linkInsteadOfSignIn && auth.currentUser != null) {
        // Zaten bir oturum varsa (örn e-posta), telefonu bu oturuma BAĞLA
        await auth.currentUser!.linkWithCredential(credential);
      } else {
        // Oturum yoksa veya bağlama istenmiyorsa direkt giriş yap
        await auth.signInWithCredential(credential);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return 'Bu telefon numarası zaten hesabınıza bağlı.';
      }
      if (e.code == 'credential-already-in-use') {
        return 'Bu telefon numarası başka bir hesap tarafından kullanılıyor.';
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'Doğrulama başarısız: $e';
    }
  }

  /// Mevcut oturuma e-posta ve şifreyi bağlar (Eğer telefonla girilmişse)
  Future<String?> linkEmailWithExistingAccount({
    required String email,
    required String password,
  }) async {
    try {
      if (auth.currentUser == null) return 'Oturum bulunamadı.';
      
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await auth.currentUser!.linkWithCredential(credential);
      // Bağlandıktan sonra onay maili gönder
      await auth.currentUser!.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return 'Bu e-posta zaten hesabınıza bağlı.';
      }
      if (e.code == 'credential-already-in-use') {
        return 'Bu e-posta adresi başka bir hesap tarafından kullanılıyor.';
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'E-posta bağlama hatası: $e';
    }
  }

  // ────────────────────────────────────────
  // 5. KULLANICI PROFİLİNİ FIRESTORE'A KAYDET
  // ────────────────────────────────────────
  Future<String?> saveUserProfile(UserModel userModel) async {
    try {
      await firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toMap());
      return null;
    } catch (e) {
      return 'Profil kaydedilemedi: $e';
    }
  }

  // ────────────────────────────────────────
  // 6. DOĞRULAMA MALİ TEKRAR GÖNDER
  // ────────────────────────────────────────
  Future<String?> resendVerificationEmail() async {
    try {
      await auth.currentUser?.sendEmailVerification();
      return null;
    } catch (e) {
      return 'Doğrulama maili gönderilemedi: \$e';
    }
  }

  // ────────────────────────────────────────
  // 7. ŞİFRE SIFIRLAMA E-POSTASI
  // ────────────────────────────────────────
  Future<String?> sendPasswordReset({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'Sıfırlama maili gönderilemedi: $e';
    }
  }

  // ────────────────────────────────────────
  // 7. ÇIKIŞ YAP
  // ────────────────────────────────────────
  Future<void> signOut() async {
    await auth.signOut();
  }

  // ────────────────────────────────────────
  // 8. ŞİFRE DOĞRULAMA (Client-Side)
  // En az 8 karakter, en az 1 özel karakter
  // ────────────────────────────────────────
  static String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      return 'Şifre en az 1 özel karakter içermelidir (!@#\$% vb.)';
    }
    return null; // Geçerli
  }

  // ────────────────────────────────────────
  // HATA MESAJLARI (Türkçe)
  // ────────────────────────────────────────
  String? _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Sistemde böyle bir kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Girdiğiniz şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta ile zaten kayıt olunmuş.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'invalid-verification-code':
        return 'Girdiğiniz SMS kodu hatalı.';
      case 'session-expired':
        return 'Doğrulama oturumu sona erdi. Tekrar deneyin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen bekleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok.';
      default:
        return 'Hata: ${e.message}';
    }
  }

  // Anlık kullanıcı
  User? get currentUser => auth.currentUser;

  /// Mevcut oturumun JWT (ID Token) değerini getirir
  Future<String?> getIdToken() async {
    return await auth.currentUser?.getIdToken();
  }
}
