import 'package:cloud_firestore/cloud_firestore.dart';

/// Acil durum kişisi modeli
class EmergencyContact {
  final String name;
  final String phone;
  final String relationship; // Eş, Anne, Baba, Kardeş, Diğer

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) => EmergencyContact(
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        relationship: map['relationship'] ?? '',
      );
}

/// Ana kullanıcı profili modeli
/// Firestore'daki "users/{uid}" dokümanına birebir karşılık gelir
class UserModel {
  final String uid;

  // --- Bölüm 1: Kimlik Bilgileri ---
  final String firstName;
  final String lastName;
  final String tcNo;          // AES-256 ile şifrelenmiş olarak saklanır
  final String citizenship;   // "TC" veya "Yabancı"
  final String? passportNo;   // Yabancı uyruklular için
  final DateTime birthDate;
  final String gender;        // "Erkek", "Kadın", "Diğer"
  final String email;
  final String phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  // --- Bölüm 2: Sağlık Bilgileri ---
  final String bloodType;     // ZORUNLU: A+, A-, B+, B-, AB+, AB-, 0+, 0-
  final String? chronicDiseases;     // İsteğe bağlı
  final String? allergies;           // İsteğe bağlı (özellikle ilaç)
  final String? currentMedications;  // İsteğe bağlı

  // --- Bölüm 3: Acil Durum Kişileri ---
  final List<EmergencyContact> emergencyContacts;

  // --- Meta ---
  final DateTime createdAt;
  final bool isProfileComplete;

  final String? profilePictureUrl; // Profil fotoğrafı URL'i

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.tcNo,
    required this.citizenship,
    this.passportNo,
    required this.birthDate,
    required this.gender,
    required this.email,
    required this.phone,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.bloodType,
    this.chronicDiseases,
    this.allergies,
    this.currentMedications,
    required this.emergencyContacts,
    required this.createdAt,
    this.isProfileComplete = false,
    this.profilePictureUrl,
  });

  /// Firestore'a yazılacak Map formatı
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'tcNo': tcNo, // Şifrelenmiş hali yazılacak
        'citizenship': citizenship,
        'passportNo': passportNo,
        'birthDate': Timestamp.fromDate(birthDate),
        'gender': gender,
        'email': email,
        'phone': phone,
        'isEmailVerified': isEmailVerified,
        'isPhoneVerified': isPhoneVerified,
        'bloodType': bloodType,
        'chronicDiseases': chronicDiseases,
        'allergies': allergies,
        'currentMedications': currentMedications,
        'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
        'isProfileComplete': isProfileComplete,
        'profilePictureUrl': profilePictureUrl,
      };

  /// Firestore'dan okuyunca UserModel'e çevirme
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] ?? '',
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        tcNo: map['tcNo'] ?? '',
        citizenship: map['citizenship'] ?? 'TC',
        passportNo: map['passportNo'],
        birthDate: (map['birthDate'] as Timestamp).toDate(),
        gender: map['gender'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        isEmailVerified: map['isEmailVerified'] ?? false,
        isPhoneVerified: map['isPhoneVerified'] ?? false,
        bloodType: map['bloodType'] ?? '',
        chronicDiseases: map['chronicDiseases'],
        allergies: map['allergies'],
        currentMedications: map['currentMedications'],
        emergencyContacts: (map['emergencyContacts'] as List<dynamic>? ?? [])
            .map((e) => EmergencyContact.fromMap(e as Map<String, dynamic>))
            .toList(),
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        isProfileComplete: map['isProfileComplete'] ?? false,
        profilePictureUrl: map['profilePictureUrl'],
      );

  /// UserModel kopyalama (copyWith)
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? tcNo,
    String? citizenship,
    String? passportNo,
    DateTime? birthDate,
    String? gender,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? bloodType,
    String? chronicDiseases,
    String? allergies,
    String? currentMedications,
    List<EmergencyContact>? emergencyContacts,
    DateTime? createdAt,
    bool? isProfileComplete,
    String? profilePictureUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      tcNo: tcNo ?? this.tcNo,
      citizenship: citizenship ?? this.citizenship,
      passportNo: passportNo ?? this.passportNo,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      bloodType: bloodType ?? this.bloodType,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  /// Tam ad
  String get fullName => '$firstName $lastName';
}
