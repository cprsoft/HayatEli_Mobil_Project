import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship; 
  final String? profilePictureUrl;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'profilePictureUrl': profilePictureUrl,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) => EmergencyContact(
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        relationship: map['relationship'] ?? '',
        profilePictureUrl: map['profilePictureUrl'],
      );
}

class UserModel {
  final String uid;

  final String firstName;
  final String lastName;
  final String tcNo;          
  final String citizenship;   
  final String? passportNo;   
  final DateTime birthDate;
  final String gender;        
  final String email;
  final String phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  final String bloodType;     
  final String? chronicDiseases;     
  final String? allergies;           
  final String? currentMedications;  

  final List<EmergencyContact> emergencyContacts;

  final DateTime createdAt;
  final bool isProfileComplete;

  final String? profilePictureUrl; 

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

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'tcNo': tcNo, 
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

  String get fullName => '$firstName $lastName';
}
