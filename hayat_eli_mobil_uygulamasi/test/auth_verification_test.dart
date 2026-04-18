import 'package:flutter_test/flutter_test.dart';
import 'package:hayat_eli_mobil_uygulamasi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hayat_eli_mobil_uygulamasi/services/email_service.dart';

// Manuel Mock Sınıfları (Paket bağımlılığı olmadan)
class MockEmailService implements EmailService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth implements FirebaseAuth {
  bool createUserCalled = false;
  bool signInCalled = false;
  bool shouldFailWithEmailInUse = false;
  final MockUser mockUser = MockUser();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    createUserCalled = true;
    if (shouldFailWithEmailInUse) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    return MockUserCredential(mockUser);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    signInCalled = true;
    return MockUserCredential(mockUser);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;
  MockUserCredential(this.user);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUser implements User {
  bool sendVerificationCalled = false;
  @override
  bool emailVerified = false;

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {
    sendVerificationCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('E-posta Kayıt ve Doğrulama Manuel Testi', () {
    test('Yeni kullanıcı için mail tetiklenmeli', () async {
      final mockAuth = MockFirebaseAuth();
      final authService = AuthService(auth: mockAuth, firestore: FirebaseFirestore.instance, emailService: MockEmailService());

      await authService.registerWithEmail(email: 'test@test.com', password: '123Password!');

      expect(mockAuth.createUserCalled, isTrue);
      expect(mockAuth.mockUser.sendVerificationCalled, isTrue);
    });

    test('Mevcut ama onaylanmamış kullanıcıyı tekrar tetiklemeli', () async {
      final mockAuth = MockFirebaseAuth();
      mockAuth.shouldFailWithEmailInUse = true;
      final authService = AuthService(auth: mockAuth, firestore: FirebaseFirestore.instance, emailService: MockEmailService());

      await authService.registerWithEmail(email: 'test@test.com', password: '123Password!');

      expect(mockAuth.createUserCalled, isTrue);
      expect(mockAuth.signInCalled, isTrue);
      expect(mockAuth.mockUser.sendVerificationCalled, isTrue);
    });
  });
}
