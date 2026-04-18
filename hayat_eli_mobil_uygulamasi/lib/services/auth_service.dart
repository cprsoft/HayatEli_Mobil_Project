import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'email_service.dart';

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
    emailService: ref.read(emailServiceProvider),
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
  final EmailService emailService;

  // Telefon doğrulama için geçici saklamalar
  String? _verificationId;

  AuthService({
    required this.auth,
    required this.firestore,
    required this.emailService,
  });

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
        // Zaten bağlıysa amaç hasıl olmuştur, hata döndürme (başarı say)
        return null;
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
        // Zaten bağlıysa hata döndürme (başarı say)
        return null; 
      }
      if (e.code == 'credential-already-in-use') {
        return 'Bu e-posta adresi başka bir hesap tarafından kullanılıyor.';
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'E-posta bağlama hatası: $e';
    }
  }

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
  // 5.1. BENZERSİZLİK KONTROLÜ (E-Posta / Telefon)
  // ────────────────────────────────────────
  Future<String?> checkEmailOrPhoneUsage({
    required String? email,
    required String? phone,
    required String excludeUid,
  }) async {
    try {
      if (email != null) {
        final emailQuery = await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        
        for (var doc in emailQuery.docs) {
          if (doc.id != excludeUid) return 'Lütfen kendi e-posta adresinizi girin.';
        }
      }

      if (phone != null) {
        final phoneQuery = await firestore
            .collection('users')
            .where('phone', isEqualTo: phone)
            .get();
        
        for (var doc in phoneQuery.docs) {
          if (doc.id != excludeUid) return 'Lütfen kendi telefon numaranızı girin.';
        }
      }
      return null;
    } catch (e) {
      return 'Kullanım kontrolü sırasında hata: $e';
    }
  }

  // ────────────────────────────────────────
  // 5.2. AUTH BİLGİLERİNİ GÜNCELLE
  // ────────────────────────────────────────
  
  /// Kritik işlemler öncesi şifre ile yeniden doğrulama yapar
  Future<String?> reauthenticate(String password) async {
    try {
      final user = auth.currentUser;
      if (user == null || user.email == null) return 'Oturum bulunamadı.';
      
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return 'Girdiğiniz şifre hatalı.';
      return _handleAuthError(e);
    } catch (e) {
      return 'Doğrulama hatası: $e';
    }
  }

  /// Firebase Auth üzerindeki e-postayı anında günceller.
  /// Not: Bu metot reauthenticate() yapıldıktan hemen sonra çağrılmalıdır.
  Future<String?> updateAuthEmail(String newEmail) async {
    try {
      final user = auth.currentUser;
      if (user == null) return 'Oturum bulunamadı.';
      
      // updateEmail son sürümlerde kaldırılmış veya kısıtlanmış olabilir.
      // verifyBeforeUpdateEmail hem daha güvenli hem de desteklenen yöntemdir.
      await user.verifyBeforeUpdateEmail(newEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Güvenlik nedeniyle şifrenizi tekrar girmeniz gerekir.';
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'Auth e-posta güncelleme hatası: $e';
    }
  }

  /// Firebase Auth üzerindeki telefonu günceller (veya bağlar)
  Future<String?> updateAuthPhone(PhoneAuthCredential credential) async {
    try {
      final user = auth.currentUser;
      if (user == null) return 'Oturum bulunamadı.';
      
      // Kullanıcının hali hazırda bir telefonu varsa updatePhoneNumber, yoksa linkWithCredential kullanılır.
      bool hasPhone = user.providerData.any((p) => p.providerId == 'phone');
      
      if (hasPhone) {
        await user.updatePhoneNumber(credential);
      } else {
        await user.linkWithCredential(credential);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Güvenlik nedeniyle telefon güncellemek için yakın zamanda giriş yapmış olmanız gerekir.';
      }
      return _handleAuthError(e);
    } catch (e) {
      return 'Auth telefon güncelleme hatası: $e';
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

  // ────────────────────────────────────────
  // 10. E-POSTA OTP (6 HANELİ KOD) SİSTEMİ
  // ────────────────────────────────────────

  /// E-posta OTP kodu gönderir (EmailJS kullanır)
  Future<String?> sendEmailOtp({required String email}) async {
    try {
      // 1. 6 Haneli rastgele kod üret
      final random = Random();
      final otpCode = (100000 + random.nextInt(900000)).toString();
 
      // 2. Doğrulama kaydını oluştur (5 dakika geçerli)
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      
      await firestore.collection('temp_verifications').doc(email).set({
        'code': otpCode,
        'expiresAt': expiresAt.toIso8601String(),
      });

      // 3. EmailJS üzerinden gönder
      final success = await emailService.sendEmailOtp(
        email: email,
        otpCode: otpCode,
      );

      if (!success) return 'E-posta servisi şu an kullanılamıyor.';

      return null; // Başarılı
    } catch (e) {
      return 'E-posta kodu gönderilemedi: $e';
    }
  }

  /// Kullanıcının girdiği 6 haneli kodu kontrol eder
  Future<bool> verifyEmailOtp({required String email, required String code}) async {
    try {
      final doc = await firestore.collection('temp_verifications').doc(email).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final correctCode = data['code'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);

      if (DateTime.now().isAfter(expiresAt)) {
        // Süresi dolmuş
        await firestore.collection('temp_verifications').doc(email).delete();
        return false;
      }

      if (correctCode == code) {
        // Başarılı, kaydı silebiliriz (veya kalsın, biz state'i güncelleriz)
        await firestore.collection('temp_verifications').doc(email).delete();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  User? get currentUser => auth.currentUser;

  /// Mevcut oturumun JWT (ID Token) değerini getirir
  Future<String?> getIdToken() async {
    return await auth.currentUser?.getIdToken();
  }

  // ────────────────────────────────────────
  // PROFİL FOTOĞRAFI UPLOAD (Firebase Storage)
  // ────────────────────────────────────────

  /// Fotoğrafı Storage'a yükler, indirme URL'ini döner.
  /// Hata durumunda null döner (kayıt yine de devam eder).
  Future<String?> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      // Güvenli yol: sadece uid ile isimlendirilen klasöre yaz
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('profile.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // Upload başarısız olursa kayıt iptal etme, sadece null dön
      return null;
    }
  }
}
