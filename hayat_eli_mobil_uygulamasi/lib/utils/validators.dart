/// Merkezi Doğrulama ve Güvenlik Motoru
/// Bu dosya WAF'sız (Web Application Firewall) ortamda manuel güvenlik katmanı sağlar.
/// Korunulan saldırı vektörleri:
///   - XSS (Cross-Site Scripting)
///   - SQL Injection
///   - NoSQL Injection (Firestore için)
///   - RCE (Remote Code Execution) tetikleyicileri
///   - CSRF destek kontrolleri (input tarafı)
///   - Path Traversal
///   - Command Injection
///   - Template Injection (SSTI)
///   - Format String Attacks
library;

import 'dart:io';
import 'package:path/path.dart' as p;

class Validators {
  // ──────────────────────────────────────────────────────────────
  // 0. DOSYA / PROFIL FOTOĞRAFI DOĞRULAMA
  // ──────────────────────────────────────────────────────────────
  
  /// Dosya formatı ve boyutu kontrolü (Vesikalık/Profil Fotoğrafı için)
  static String? validateImageFile(File? file, {int maxSizeInBytes = 2 * 1024 * 1024}) {
    if (file == null) return null; // Fotoğraf isteğe bağlıysa

    if (!file.existsSync()) return 'Seçilen dosya bulunamadı.';

    // 1. Boyut Kotrolü (2MB)
    if (file.lengthSync() > maxSizeInBytes) {
      return 'Fotoğraf boyutu 2 MB\'dan küçük olmalıdır.';
    }

    // 2. Uzantı Kontrolü (Güvenlik için exe vb. engelleme)
    final extension = p.extension(file.path).toLowerCase().replaceAll('.', '');
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    
    if (!allowedExtensions.contains(extension)) {
      return 'Yalnızca görsel formatları (JPG, PNG, WEBP) kabul edilmektedir.\nZararlı veya geçersiz dosya tipi tespit edildi.';
    }

    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 1. E-POSTA DOĞRULAMA
  // Yalnızca kişisel büyük e-posta sağlayıcıları — kurumsal domain yok
  // ──────────────────────────────────────────────────────────────

  static const List<String> _allowedDomains = [
    // Google
    'gmail.com', 'googlemail.com',
    // Microsoft
    'hotmail.com', 'hotmail.com.tr',
    'outlook.com', 'outlook.com.tr',
    'live.com', 'live.com.tr', 'msn.com',
    // Yahoo
    'yahoo.com', 'yahoo.com.tr',
    // Apple
    'icloud.com', 'me.com', 'mac.com',
    // Yandex
    'yandex.com', 'yandex.ru',
  ];

  /// Bilinen tek kullanımlık (disposable) ve geçici mail domain'leri
  static const List<String> _blockedDomains = [
    'mailinator.com', 'guerrillamail.com', 'tempmail.com',
    'throwam.com', '10minutemail.com', 'yopmail.com',
    'trashmail.com', 'fakeinbox.com', 'getairmail.com',
    'sharklasers.com', 'guerrillamail.info', 'guerrillamail.biz',
    'guerrillamail.de', 'grr.la', 'guerrillamailblock.com',
    'spam4.me', 'maildrop.cc', 'dispostable.com', 'mailnull.com',
    'mailforspam.com', 'trashmail.at', 'discard.email',
    'throwam.com', 'spamgourmet.com', 'spamfree24.org',
    'tempr.email', 'emailondeck.com', 'burnermail.io',
  ];

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur.';
    }

    final email = value.trim().toLowerCase();

    // Format kontrolü
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi girin.';
    }

    // Güvenlik filtresi: Injection karakterleri
    if (_containsAttackPatterns(value)) {
      return 'E-posta adresinde geçersiz karakter bulundu.';
    }

    final domain = email.split('@').last;

    // Tek kullanımlık mail kontrolü
    if (_blockedDomains.any((d) => domain == d || domain.endsWith('.$d'))) {
      return 'Tek kullanımlık e-posta adresleri kabul edilmemektedir.';
    }

    // Yalnızca kişisel büyük sağlayıcılar
    final isAllowed = _allowedDomains.contains(domain);
    if (!isAllowed) {
      return 'Lütfen Gmail, Outlook, Yahoo veya iCloud gibi kişisel e-posta adresi kullanın.\n(Kurumsal, okul veya geçici e-posta kabul edilmez.)';
    }

    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 2. TELEFON NUMARASI DOĞRULAMA
  // ──────────────────────────────────────────────────────────────

  static String? validatePhone(String? number, {String dialCode = '+90'}) {
    if (number == null || number.trim().isEmpty) {
      return 'Telefon numarası zorunludur.';
    }
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Telefon numarası yalnızca rakam içermelidir.';
    }

    if (dialCode == '+90') {
      if (cleaned.length != 10) {
        return "Türkiye numarası 10 haneli olmalıdır (5XX XXX XXXX formatında).";
      }
      if (!RegExp(r'^5[0-9]{9}$').hasMatch(cleaned)) {
        return 'Geçerli bir Türkiye cep numarası girin (5XX ile başlamalı).';
      }
    } else {
      if (cleaned.length < 6 || cleaned.length > 15) {
        return 'Geçerli bir telefon numarası girin (6-15 hane).';
      }
    }
    return null;
  }

  static String formatPhone(String number, String dialCode) {
    final cleaned = number.replaceAll(RegExp(r'[\s\-()]'), '');
    return '$dialCode$cleaned';
  }

  // ──────────────────────────────────────────────────────────────
  // 3. T.C. KİMLİK NO DOĞRULAMA (Matematiksel algoritma)
  // ──────────────────────────────────────────────────────────────

  static String? validateTcNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'T.C. Kimlik Numarası zorunludur.';
    }
    final tc = value.trim();
    if (tc.length != 11) return 'T.C. Kimlik No 11 haneli olmalıdır.';
    if (!RegExp(r'^\d{11}$').hasMatch(tc)) {
      return 'T.C. Kimlik No yalnızca rakam içermelidir.';
    }
    if (tc[0] == '0') return 'T.C. Kimlik No 0 ile başlayamaz.';

    final d = tc.split('').map(int.parse).toList();
    final d10 = ((d[0] + d[2] + d[4] + d[6] + d[8]) * 7 -
            (d[1] + d[3] + d[5] + d[7])) %
        10;
    final d11 =
        (d[0] + d[1] + d[2] + d[3] + d[4] + d[5] + d[6] + d[7] + d[8] + d[9]) %
            10;

    if (d[9] != d10 || d[10] != d11) {
      return 'Girdiğiniz T.C. Kimlik Numarası geçersiz.';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 4. ŞİFRE DOĞRULAMA
  // ──────────────────────────────────────────────────────────────

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre zorunludur.';
    if (value.length < 10) return 'Şifre en az 10 karakter olmalıdır.';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Şifre en az 1 büyük harf içermelidir.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Şifre en az 1 rakam içermelidir.';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(value)) {
      return 'Şifre en az 1 özel karakter içermelidir (!@#\$% vb.)';
    }
    return null;
  }

  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) return 'Şifreyi tekrar girin.';
    if (value != password) return 'Şifreler eşleşmiyor.';
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 5. AD SOYAD DOĞRULAMA
  // ──────────────────────────────────────────────────────────────

  static String? validateName(String? value, {String fieldName = 'Ad'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName zorunludur.';
    if (value.trim().length < 2) {
      return '$fieldName en az 2 karakter olmalıdır.';
    }
    if (_containsAttackPatterns(value)) {
      return '$fieldName geçersiz karakter içeriyor.';
    }
    // Sadece Türkçe/İngilizce harf, boşluk, tire ve nokta
    if (!RegExp(r"^[a-zA-ZğüşöçıİĞÜŞÖÇ\s'\-\.]+$").hasMatch(value.trim())) {
      return '$fieldName yalnızca harf içermelidir.';
    }
    if (value.trim().length > 100) {
      return '$fieldName çok uzun (en fazla 100 karakter).';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 6. ZORUNLU ALAN
  // ──────────────────────────────────────────────────────────────

  static String? validateRequired(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName zorunludur.';
    if (_containsAttackPatterns(value)) {
      return '$fieldName geçersiz karakter içeriyor.';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 7. SERBEST METİN ALANLARI (Alerji, Kronik Hastalık, İlaçlar vb.)
  // Bu alanlar isteğe bağlıdır ama güvenli olmalıdır.
  // ──────────────────────────────────────────────────────────────

  /// Alerji, kronik hastalık, ilaç gibi serbest metin alanları için
  static String? validateFreeText(String? value, {String fieldName = 'Alan'}) {
    if (value == null || value.trim().isEmpty) return null; // İsteğe bağlı

    if (_containsAttackPatterns(value)) {
      return '$fieldName geçersiz karakter içeriyor.';
    }

    if (value.trim().length > 1000) {
      return '$fieldName en fazla 1000 karakter olabilir.';
    }

    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 8. PASAPORT NO
  // ──────────────────────────────────────────────────────────────

  static String? validatePassport(String? value) {
    if (value == null || value.trim().isEmpty) return 'Pasaport no zorunludur.';
    if (_containsAttackPatterns(value)) return 'Pasaport no geçersiz karakter içeriyor.';
    if (!RegExp(r'^[A-Z0-9]{6,20}$', caseSensitive: false).hasMatch(value.trim())) {
      return 'Geçerli bir pasaport numarası girin (6-20 karakter, harf ve rakam).';
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // !! GÜVENLIK FILTRESI — TÜM SALDIRI VEKTÖRLERİ !!
  // WAF olmayan ortamda manuel koruma katmanı
  // ──────────────────────────────────────────────────────────────

  /// Tüm bilinen saldırı kalıplarını tek noktada kontrol eder.
  /// Korunan vektörler:
  ///   XSS, HTML Injection, SQL Injection, NoSQL Injection,
  ///   Command Injection, RCE, Path Traversal, Template Injection,
  ///   LDAP Injection, Format String, CRLF Injection
  static bool _containsAttackPatterns(String value) {
    // ── XSS & HTML Injection ──
    final xss = RegExp(
      r'<[^>]*>|javascript:|vbscript:|data:|on\w+\s*=|alert\s*\(|'
      r'prompt\s*\(|confirm\s*\(|document\.|window\.|eval\s*\(|'
      r'expression\s*\(|url\s*\(|&lt;|&gt;|&#x|&#\d',
      caseSensitive: false,
    );

    // ── SQL Injection ──
    final sql = RegExp(
      r'''('|")\s*(OR|AND|UNION|SELECT|INSERT|UPDATE|DELETE|DROP|'''
      r'CREATE|ALTER|EXEC|EXECUTE|TRUNCATE|GRANT|REVOKE|MERGE)\s'
      r'|--|\bOR\b\s+\d+=\d+|\bAND\b\s+\d+=\d+'
      r'|\/\*.*?\*\/|\bXP_\w+',
      caseSensitive: false,
    );

    // ── NoSQL Injection (Firestore/MongoDB) ──
    final nosql = RegExp(
      r'\$where|\$gt|\$lt|\$ne|\$in|\$nin|\$or|\$and|\$not|\$nor|'
      r'\$exists|\$type|\$mod|\$regex|\$text|\$where|\{.*:.*\}',
      caseSensitive: false,
    );

    // ── Command Injection & RCE ──
    final cmd = RegExp(
      r';\s*(ls|cat|rm|mv|cp|wget|curl|bash|sh|cmd|powershell|'
      r'python|ruby|perl|php|node|exec|system|passthru|popen)\b|'
      r'\|\s*\w+|\`[^`]*\`|\$\([^)]*\)|&&|\|\|',
      caseSensitive: false,
    );

    // ── Path Traversal ──
    final pathTraversal = RegExp(
      r'\.\./|\.\.\\|%2e%2e|%252e%252e|\.\.%2f|\.\.%5c',
      caseSensitive: false,
    );

    // ── Template/SSTI Injection ──
    final ssti = RegExp(
      r'\{\{.*\}\}|\{%.*%\}|\${.*}|\#\{.*\}',
    );

    // ── CRLF Injection ──
    final crlf = RegExp(r'\r|\n|\%0d|\%0a', caseSensitive: false);

    // ── LDAP Injection ──
    final ldap = RegExp(r'[)(|!\\*\x00]');

    // ── Format String ──
    final fmt = RegExp(r'%[0-9]*[diouxXeEfgGs]|%n|%p');

    return xss.hasMatch(value) ||
        sql.hasMatch(value) ||
        nosql.hasMatch(value) ||
        cmd.hasMatch(value) ||
        pathTraversal.hasMatch(value) ||
        ssti.hasMatch(value) ||
        crlf.hasMatch(value) ||
        ldap.hasMatch(value) ||
        fmt.hasMatch(value);
  }

  // ──────────────────────────────────────────────────────────────
  // 9. TEMİZLEME (SANITIZATION) — Firestore'a yazmadan önce uygula
  // ──────────────────────────────────────────────────────────────

  /// Girdiyi tüm tehlikeli karakterlerden temizler.
  /// Kullanım: Firestore'a yazmadan hemen önce çağrılmalıdır.
  static String sanitize(String input) {
    return input
        .trim()
        // HTML / Script taglerini kaldır
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Tehlikeli özel karakterleri encode et
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        // Kontrol karakterlerini temizle (null byte dahil)
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        // Uzun boşlukları tekile indir
        .replaceAll(RegExp(r'  +'), ' ');
  }

  // ──────────────────────────────────────────────────────────────
  // 10. ALAN KODU LİSTESİ
  // ──────────────────────────────────────────────────────────────

  static const List<Map<String, String>> dialCodes = [
    {'code': '+90', 'country': '🇹🇷 Türkiye'},
    {'code': '+1', 'country': '🇺🇸 ABD/Kanada'},
    {'code': '+44', 'country': '🇬🇧 İngiltere'},
    {'code': '+49', 'country': '🇩🇪 Almanya'},
    {'code': '+33', 'country': '🇫🇷 Fransa'},
    {'code': '+31', 'country': '🇳🇱 Hollanda'},
    {'code': '+32', 'country': '🇧🇪 Belçika'},
    {'code': '+41', 'country': '🇨🇭 İsviçre'},
    {'code': '+43', 'country': '🇦🇹 Avusturya'},
    {'code': '+46', 'country': '🇸🇪 İsveç'},
    {'code': '+47', 'country': '🇳🇴 Norveç'},
    {'code': '+45', 'country': '🇩🇰 Danimarka'},
    {'code': '+358', 'country': '🇫🇮 Finlandiya'},
    {'code': '+7', 'country': '🇷🇺 Rusya'},
    {'code': '+994', 'country': '🇦🇿 Azerbaycan'},
    {'code': '+993', 'country': '🇹🇲 Türkmenistan'},
    {'code': '+992', 'country': '🇹🇯 Tacikistan'},
    {'code': '+996', 'country': '🇰🇬 Kırgızistan'},
    {'code': '+998', 'country': '🇺🇿 Özbekistan'},
    {'code': '+966', 'country': '🇸🇦 Suudi Arabistan'},
    {'code': '+971', 'country': '🇦🇪 B. Arap Emirlikleri'},
    {'code': '+90392', 'country': '🇨🇾 KKTC'},
    {'code': '+30', 'country': '🇬🇷 Yunanistan'},
    {'code': '+359', 'country': '🇧🇬 Bulgaristan'},
    {'code': '+40', 'country': '🇷🇴 Romanya'},
    {'code': '+36', 'country': '🇭🇺 Macaristan'},
    {'code': '+48', 'country': '🇵🇱 Polonya'},
    {'code': '+81', 'country': '🇯🇵 Japonya'},
    {'code': '+86', 'country': '🇨🇳 Çin'},
    {'code': '+91', 'country': '🇮🇳 Hindistan'},
    {'code': '+55', 'country': '🇧🇷 Brezilya'},
    {'code': '+61', 'country': '🇦🇺 Avustralya'},
  ];
}
