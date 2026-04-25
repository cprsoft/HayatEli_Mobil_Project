import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../utils/validators.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _chronicDiseasesController;
  late TextEditingController _allergiesController;
  late TextEditingController _currentMedicationsController;

  String _selectedCountryCode = '+90';
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _chronicDiseasesController = TextEditingController();
    _allergiesController = TextEditingController();
    _currentMedicationsController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _chronicDiseasesController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
    super.dispose();
  }

  void _syncControllers(UserModel? editedUser) {
    if (editedUser == null || _isInit) return;
    
    String phone = editedUser.phone;
    for (final c in Validators.dialCodes) {
      if (phone.startsWith(c['code']!)) {
        _selectedCountryCode = c['code']!;
        phone = phone.substring(c['code']!.length).trim();
        break;
      }
    }

    _emailController.text = editedUser.email;
    _phoneController.text = phone;
    _chronicDiseasesController.text = editedUser.chronicDiseases ?? '';
    _allergiesController.text = editedUser.allergies ?? '';
    _currentMedicationsController.text = editedUser.currentMedications ?? '';

    _isInit = true;
  }

  void _onFieldChanged() {
    ref.read(profileControllerProvider.notifier).updateField(
      email: _emailController.text.trim(),
      phone: '$_selectedCountryCode${_phoneController.text.trim()}',
      chronicDiseases: _chronicDiseasesController.text.trim(),
      allergies: _allergiesController.text.trim(),
      currentMedications: _currentMedicationsController.text.trim(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Kare oran
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Kırp',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Kırp',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        await ref.read(profileControllerProvider.notifier).uploadProfilePicture(File(croppedFile.path));
      }
    }
  }

  void _showEmailOtpDialog() {
    String otpCode = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('E-Posta Doğrulama', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yeni e-posta adresinize 6 haneli bir kod gönderdik.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              const SizedBox(height: 15),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                onChanged: (val) => otpCode = val,
                decoration: const InputDecoration(counterText: "", hintText: "000000", hintStyle: TextStyle(color: Colors.black26)),
              ),
              const SizedBox(height: 10),
                builder: (ctx, ref, _) {
                  final s = ref.watch(profileControllerProvider);
                  return Column(
                    children: [
                      Text(
                        'Kalan Süre: ${s.emailSecondsLeft}sn',
                        style: TextStyle(color: s.emailSecondsLeft > 0 ? Colors.black : Colors.red),
                      ),
                      if (s.error != null && s.error!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(s.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  );
                }
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(profileControllerProvider.notifier).updateField(email: ref.read(profileControllerProvider).originalUser?.email);
                Navigator.pop(ctx);
              },
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            Consumer(
              builder: (ctx, ref, _) {
                final s = ref.watch(profileControllerProvider);
                return ElevatedButton(
                  onPressed: s.isLoading ? null : () async {
                    if (otpCode.length == 6) {
                      bool success = await ref.read(profileControllerProvider.notifier).verifyEmailOtp(otpCode);
                      if (success && ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Posta doğrulandı!')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: s.isLoading
                    ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Doğrula', style: TextStyle(color: Colors.white)),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  void _showPhoneOtpDialog() {
    String otpCode = '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('SMS Doğrulama', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yeni telefon numaranıza SMS kodu gönderdik.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              onChanged: (val) => otpCode = val,
              decoration: const InputDecoration(counterText: "", hintText: "******"),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (ctx, ref, _) {
                final s = ref.watch(profileControllerProvider);
                return Column(
                  children: [
                    Text('Kalan Süre: ${s.phoneSecondsLeft}sn', style: TextStyle(color: s.phoneSecondsLeft > 0 ? Colors.black : Colors.red)),
                    if (s.error != null && s.error!.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 6), child: Text(s.error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                  ],
                );
              }
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(profileControllerProvider.notifier).updateField(phone: ref.read(profileControllerProvider).originalUser?.phone);
              Navigator.pop(ctx);
            },
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final s = ref.watch(profileControllerProvider);
              return ElevatedButton(
                onPressed: s.isLoading ? null : () async {
                  if (otpCode.length == 6) {
                    bool success = await ref.read(profileControllerProvider.notifier).verifyPhoneOtp(otpCode);
                    if (success && ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Telefon doğrulandı!')));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: s.isLoading
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Doğrula', style: TextStyle(color: Colors.white)),
              );
            }
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactDialog({int? index, EmergencyContact? existing}) {
    String name = existing?.name ?? '';
    String rawPhone = existing?.phone ?? '';
    String dialCode = '+90';
    String phone = rawPhone;
    
    for (final c in Validators.dialCodes) {
      if (rawPhone.startsWith(c['code']!)) {
        dialCode = c['code']!;
        phone = rawPhone.substring(c['code']!.length).trim();
        break;
      }
    }

    String relationship = existing?.relationship ?? 'Diğer';
    String? photoUrl = existing?.profilePictureUrl;
    File? localImage;

    final relationships = ['Anne', 'Baba', 'Kardeş', 'Eş', 'Çocuk', 'Akraba', 'Arkadaş', 'Diğer'];
    if (!relationships.contains(relationship)) relationship = 'Diğer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(index == null ? 'Acil Durum Kişisi Ekle' : 'Kişiyi Düzenle', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: localImage != null 
                            ? FileImage(localImage!) 
                            : (photoUrl != null ? NetworkImage(photoUrl) : null),
                        child: (localImage == null && photoUrl == null)
                            ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                            if (img != null) {
                              final croppedFile = await ImageCropper().cropImage(
                                sourcePath: img.path,
                                aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: 'Kişi Fotoğrafını Kırp',
                                    toolbarColor: Colors.red,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio: CropAspectRatioPreset.square,
                                    lockAspectRatio: true,
                                  ),
                                  IOSUiSettings(
                                    title: 'Kişi Fotoğrafını Kırp',
                                    aspectRatioLockEnabled: true,
                                  ),
                                ],
                              );
                              if (croppedFile != null) {
                                setDialogState(() => localImage = File(croppedFile.path));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  decoration: const InputDecoration(labelText: 'İsim Soyisim *', prefixIcon: Icon(Icons.person_outline)),
                  onChanged: (v) => name = v,
                  controller: TextEditingController(text: name)..selection = TextSelection.collapsed(offset: name.length),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dialCode,
                          items: Validators.dialCodes.map((c) => DropdownMenuItem(value: c['code'], child: Text(c['code']!, style: const TextStyle(fontSize: 14)))).toList(),
                          onChanged: (v) => setDialogState(() => dialCode = v!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Telefon *', hintText: '5XX XXX XXXX'),
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => phone = v,
                        controller: TextEditingController(text: phone)..selection = TextSelection.collapsed(offset: phone.length),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: relationship,
                  items: relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) { setDialogState(() => relationship = v!); },
                  decoration: const InputDecoration(labelText: 'Yakınlık Derecesi', prefixIcon: Icon(Icons.people_outline)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                final phoneErr = Validators.validatePhone(phone, dialCode: dialCode);
                
                if (nameErr != null || phoneErr != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nameErr ?? phoneErr!)));
                  return;
                }

                String? finalPhotoUrl = photoUrl;
                if (localImage != null) {
                  final uploadedUrl = await ref.read(profileControllerProvider.notifier).uploadContactPicture(localImage!, name);
                  if (uploadedUrl != null) finalPhotoUrl = uploadedUrl;
                }

                final contact = EmergencyContact(
                  name: name, 
                  phone: Validators.formatPhone(phone, dialCode), 
                  relationship: relationship, 
                  profilePictureUrl: finalPhotoUrl,
                );
                
                if (index != null) {
                  ref.read(profileControllerProvider.notifier).removeEmergencyContact(index);
                  ref.read(profileControllerProvider.notifier).addEmergencyContactAt(index, contact);
                } else {
                  ref.read(profileControllerProvider.notifier).addEmergencyContact(contact);
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    String pwd = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Güvenlik Onayı', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('İletişim bilgilerini değiştirmek için lütfen mevcut şifrenizi girin.', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre', prefixIcon: Icon(Icons.lock_outline)),
              onChanged: (v) => pwd = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool isSuccess = await ref.read(profileControllerProvider.notifier).saveProfile(password: pwd);
              if (isSuccess && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profil ve giriş bilgileri başarıyla güncellendi!')));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Doğrula ve Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    ref.listen(profileControllerProvider, (previous, next) {
      if (previous?.showEmailVerificationDialog != true && next.showEmailVerificationDialog == true) _showEmailOtpDialog();
      if (previous?.showPhoneVerificationDialog != true && next.showPhoneVerificationDialog == true) _showPhoneOtpDialog();
    });

    if (state.isLoading && state.originalUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.red)));
    }

    if (state.editedUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profili Düzenle', style: GoogleFonts.outfit())),
        body: const Center(child: Text('Profil verisi alınamadı')),
      );
    }

    _syncControllers(state.editedUser);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('PROFİLİ DÜZENLE', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: (state.editedUser!.profilePictureUrl?.isNotEmpty == true)
                          ? NetworkImage(state.editedUser!.profilePictureUrl!) : null,
                      child: (state.editedUser!.profilePictureUrl?.isEmpty != false)
                          ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: state.isLoading ? null : _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _sectionHeader('İLETİŞİM BİLGİLERİ'),
              
              _card(Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Posta Adresi', border: InputBorder.none, icon: Icon(Icons.email_outlined)),
                      onChanged: (_) => _onFieldChanged(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  _verificationBadge(state.isEmailVerified, onVerify: () => ref.read(profileControllerProvider.notifier).sendEmailOtp()),
                ],
              )),

              _card(Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedCountryCode,
                    underline: const SizedBox(),
                    items: Validators.dialCodes.map((c) => DropdownMenuItem(
                      value: c['code'],
                      child: Text('${c['code']}', style: const TextStyle(fontSize: 14)),
                    )).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCountryCode = val!);
                      _onFieldChanged();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telefon Numarası', border: InputBorder.none, hintText: '5XX XXX XXXX'),
                      onChanged: (_) => _onFieldChanged(),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  _verificationBadge(state.isPhoneVerified, onVerify: () => ref.read(profileControllerProvider.notifier).sendPhoneOtp()),
                ],
              )),

              const SizedBox(height: 25),
              _sectionHeader('SAĞLIK BİLGİLERİ'),

              _card(TextFormField(
                controller: _chronicDiseasesController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Kronik Hastalıklar', border: InputBorder.none, icon: Icon(Icons.monitor_heart_outlined)),
                onChanged: (_) => _onFieldChanged(),
              )),
              _card(TextFormField(
                controller: _allergiesController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Alerjiler', border: InputBorder.none, icon: Icon(Icons.science_outlined)),
                onChanged: (_) => _onFieldChanged(),
              )),
              _card(TextFormField(
                controller: _currentMedicationsController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Kullanılan İlaçlar', border: InputBorder.none, icon: Icon(Icons.medication_outlined)),
                onChanged: (_) => _onFieldChanged(),
              )),

              const SizedBox(height: 25),
              _sectionHeader('ACİL DURUM KİŞİLERİ'),
              ...state.editedUser!.emergencyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.shade100,
                      backgroundImage: contact.profilePictureUrl != null ? NetworkImage(contact.profilePictureUrl!) : null,
                      child: contact.profilePictureUrl == null 
                          ? Text(contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    title: Text(contact.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    subtitle: Text('${contact.relationship} · ${contact.phone}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), onPressed: () => _showEmergencyContactDialog(index: index, existing: contact)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => ref.read(profileControllerProvider.notifier).removeEmergencyContact(index)),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => _showEmergencyContactDialog(),
                icon: const Icon(Icons.add, color: Colors.red),
                label: const Text('Yeni Kişi Ekle', style: TextStyle(color: Colors.red)),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      final emailChanged = state.editedUser?.email != state.originalUser?.email;
                      final phoneChanged = state.editedUser?.phone != state.originalUser?.phone;

                      if (emailChanged || phoneChanged) {
                        _showPasswordDialog();
                      } else {
                        bool isSuccess = await ref.read(profileControllerProvider.notifier).saveProfile();
                        if (isSuccess && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profil başarıyla güncellendi!')));
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: state.isLoading && !state.showEmailVerificationDialog && !state.showPhoneVerificationDialog
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('DEĞİŞİKLİKLERİ KAYDET', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              if (state.error != null && !state.showEmailVerificationDialog && !state.showPhoneVerificationDialog)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Center(child: Text(state.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verificationBadge(bool isVerified, {required VoidCallback onVerify}) {
    if (isVerified) {
      return const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(Icons.check_circle, color: Colors.green),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: InkWell(
          onTap: onVerify,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text('Doğrula', style: GoogleFonts.outfit(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 5),
    child: Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey.shade700, letterSpacing: 1)),
  );

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}
