import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../utils/validators.dart';
import '../shared/auth_input_decoration.dart';

class IdentityStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final File? profileImage;
  final VoidCallback onPickImage;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController tcNoController;
  final TextEditingController passportController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final TextEditingController phoneController;
  final TextEditingController phoneOtpController;
  final TextEditingController emailOtpController;
  final String citizenship;
  final ValueChanged<String?> onCitizenshipChanged;
  final DateTime? birthDate;
  final ValueChanged<DateTime?> onBirthDateChanged;
  final String gender;
  final ValueChanged<String?> onGenderChanged;
  final String selectedDialCode;
  final ValueChanged<String?> onDialCodeChanged;
  final bool emailLinkSent;
  final bool emailVerified;
  final bool isEmailLinkExpired;
  final int emailSecondsLeft;
  final bool phoneOtpSent;
  final bool phoneVerified;
  final bool phoneOtpExpired;
  final int phoneSecondsLeft;
  final VoidCallback onSendVerificationLink;
  final VoidCallback onVerifyEmailOtp;
  final VoidCallback onResetEmailState;
  final VoidCallback onSendPhoneOtp;
  final VoidCallback onVerifyPhoneOtp;
  final VoidCallback onResetPhoneOtp;

  const IdentityStep({
    super.key,
    required this.formKey,
    this.profileImage,
    required this.onPickImage,
    required this.firstNameController,
    required this.lastNameController,
    required this.tcNoController,
    required this.passportController,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.phoneController,
    required this.phoneOtpController,
    required this.emailOtpController,
    required this.citizenship,
    required this.onCitizenshipChanged,
    this.birthDate,
    required this.onBirthDateChanged,
    required this.gender,
    required this.onGenderChanged,
    required this.selectedDialCode,
    required this.onDialCodeChanged,
    required this.emailLinkSent,
    required this.emailVerified,
    required this.isEmailLinkExpired,
    required this.emailSecondsLeft,
    required this.phoneOtpSent,
    required this.phoneVerified,
    required this.phoneOtpExpired,
    required this.phoneSecondsLeft,
    required this.onSendVerificationLink,
    required this.onVerifyEmailOtp,
    required this.onResetEmailState,
    required this.onSendPhoneOtp,
    required this.onVerifyPhoneOtp,
    required this.onResetPhoneOtp,
  });

  @override
  State<IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<IdentityStep> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  static const _kRed = Color(0xFFE53935);
  static const _kDarkRed = Color(0xFFB71C1C);

  InputDecoration _deco(String label, IconData icon) => authInputDecoration(label, icon);

  Widget _verifyBtn({required String label, required VoidCallback onTap, required bool verified}) {
    if (verified) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 4),
          Text('Doğrulandı', style: GoogleFonts.outfit(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      );
    }
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: GoogleFonts.outfit(color: _kDarkRed, fontWeight: FontWeight.bold)),
    );
  }

  Widget _ruleRow(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(children: [
      Icon(Icons.check_circle_outline, size: 14, color: Colors.amber.shade700),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 12, color: Colors.amber.shade900))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _kRed.withValues(alpha: 0.2), width: 2)),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: widget.profileImage != null ? FileImage(widget.profileImage!) : null,
                      child: widget.profileImage == null ? Icon(Icons.person, size: 50, color: Colors.grey.shade400) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 4, right: 4,
                    child: InkWell(
                      onTap: widget.onPickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: _kDarkRed, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 8),
              Center(child: Text('Profil Fotoğrafı Seçin', style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600))),
              const SizedBox(height: 20),

              Column(children: [
                Row(children: [
                  Expanded(child: TextFormField(controller: widget.firstNameController, decoration: _deco('Ad *', Icons.person),
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                    validator: (v) => Validators.validateName(v, fieldName: 'Ad'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: widget.lastNameController, decoration: _deco('Soyad *', Icons.person_outline),
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                    validator: (v) => Validators.validateName(v, fieldName: 'Soyad'))),
                ]),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: widget.citizenship,
                  decoration: _deco('Vatandaşlık *', Icons.flag_outlined),
                  items: ['TC', 'Yabancı'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: widget.onCitizenshipChanged,
                ),
                const SizedBox(height: 12),

                if (widget.citizenship == 'TC')
                  TextFormField(controller: widget.tcNoController, keyboardType: TextInputType.number, maxLength: 11,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _deco('T.C. Kimlik No *', Icons.credit_card), validator: Validators.validateTcNo)
                else
                  TextFormField(controller: widget.passportController,
                    decoration: _deco('Pasaport No *', Icons.credit_card), validator: Validators.validatePassport),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(DateTime.now().year - 20),
                      firstDate: DateTime(1920),
                      lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
                      builder: (context, child) => Theme(
                        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kRed)), child: child!),
                    );
                    if (picked != null) widget.onBirthDateChanged(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(border: Border.all(color: widget.birthDate == null ? Colors.grey.shade400 : _kRed), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.calendar_today_outlined, color: widget.birthDate == null ? Colors.grey : _kRed, size: 20),
                      const SizedBox(width: 12),
                      Text(widget.birthDate == null ? 'Doğum Tarihi Seçin * (18+)' : DateFormat('dd/MM/yyyy').format(widget.birthDate!),
                        style: GoogleFonts.outfit(color: widget.birthDate == null ? Colors.grey : Colors.black87, fontSize: 15)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: widget.gender,
                  decoration: _deco('Cinsiyet *', Icons.wc_outlined),
                  items: ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: widget.onGenderChanged,
                ),
              ]),
              const SizedBox(height: 12),

              const Divider(height: 32, thickness: 1, color: Colors.grey),
              Text('GÜVENLİK VE ONAY', 
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: _kDarkRed, letterSpacing: 1.1),
                textAlign: TextAlign.center),
              const SizedBox(height: 16),

              TextFormField(
                controller: widget.emailController, keyboardType: TextInputType.emailAddress, enabled: !widget.emailVerified,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                decoration: _deco('E-posta *', Icons.email_outlined).copyWith(
                  suffixIcon: _verifyBtn(
                    label: widget.emailLinkSent ? (widget.emailVerified ? 'Doğrulandı' : 'Doğrula') : 'Gönder', 
                    onTap: widget.emailLinkSent ? widget.onVerifyEmailOtp : widget.onSendVerificationLink,
                    verified: widget.emailVerified),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)),
                validator: Validators.validateEmail,
              ),
              if (widget.emailLinkSent && !widget.emailVerified) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isEmailLinkExpired ? Colors.red.shade50 : (widget.emailSecondsLeft <= 30 ? Colors.orange.shade50 : Colors.green.shade50),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: widget.isEmailLinkExpired ? Colors.red.shade300 : (widget.emailSecondsLeft <= 30 ? Colors.orange.shade300 : Colors.green.shade300))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Icon(widget.isEmailLinkExpired ? Icons.timer_off : Icons.timer_outlined, size: 16,
                        color: widget.isEmailLinkExpired ? Colors.red.shade700 : (widget.emailSecondsLeft <= 30 ? Colors.orange.shade700 : Colors.green.shade700)),
                      const SizedBox(width: 6),
                      Text(widget.isEmailLinkExpired ? 'Kodun süresi doldu' : 'Kalan süre: ${widget.emailSecondsLeft} sn',
                        style: GoogleFonts.outfit(
                          color: widget.isEmailLinkExpired ? Colors.red.shade700 : (widget.emailSecondsLeft <= 30 ? Colors.orange.shade700 : Colors.green.shade700),
                          fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                    if (widget.isEmailLinkExpired)
                      GestureDetector(onTap: widget.onResetEmailState,
                        child: Text('Tekrar Gönder', style: GoogleFonts.outfit(color: _kDarkRed, fontWeight: FontWeight.w800, fontSize: 13, decoration: TextDecoration.underline, decorationColor: _kDarkRed))),
                  ]),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: widget.emailOtpController, keyboardType: TextInputType.number, maxLength: 6,
                  enabled: !widget.isEmailLinkExpired, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _deco('6 Haneli E-posta Kodu', Icons.pin_outlined),
                ),
                const SizedBox(height: 4),
                Text('E-postanıza gönderilen 6 haneli kodu girin.',
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.orange.shade800)),
              ] else if (!widget.emailVerified) ...[
                const SizedBox(height: 4),
                Text('Hesabı oluşturmak için e-postayı doğrulayın.',
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
              ],
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade300)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _ruleRow('En az 10 karakter & 1 Büyük harf'),
                  _ruleRow('1 Rakam & 1 Özel karakter'),
                ]),
              ),
              const SizedBox(height: 12),

              TextFormField(controller: widget.passwordController, obscureText: _obscurePassword, enabled: !widget.emailVerified,
                decoration: _deco('Şifre *', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                validator: Validators.validatePassword),
              const SizedBox(height: 12),

              TextFormField(controller: widget.passwordConfirmController, obscureText: _obscureConfirm, enabled: !widget.emailVerified,
                decoration: _deco('Şifre Tekrar *', Icons.lock_reset_outlined).copyWith(
                  suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre onayı zorunludur.';
                  if (v != widget.passwordController.text) return 'Şifreler eşleşmiyor.';
                  return null;
                }),
              const SizedBox(height: 24),


              Opacity(
                opacity: widget.emailVerified ? 1.0 : 0.5,
                child: AbsorbPointer(
                  absorbing: !widget.emailVerified,
                  child: Column(children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12),
                          color: widget.phoneVerified ? Colors.grey.shade100 : Colors.transparent),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.selectedDialCode,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                            isDense: true,
                            onChanged: widget.emailVerified && !widget.phoneVerified ? widget.onDialCodeChanged : null,
                            items: Validators.dialCodes.map((c) => DropdownMenuItem<String>(
                              value: c['code'],
                              child: Text('${c['code']}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(
                        controller: widget.phoneController, keyboardType: TextInputType.phone, enabled: widget.emailVerified && !widget.phoneVerified,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _deco('Telefon No *', Icons.phone_outlined).copyWith(
                          suffixIcon: _verifyBtn(
                            label: widget.phoneOtpSent ? 'Doğrula' : 'Gönder',
                            onTap: (widget.emailVerified) ? (widget.phoneOtpSent ? widget.onVerifyPhoneOtp : widget.onSendPhoneOtp) : (){},
                            verified: widget.phoneVerified),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)),
                        validator: (v) => Validators.validatePhone(v, dialCode: widget.selectedDialCode))),
                    ]),
                    if (widget.phoneOtpSent && !widget.phoneVerified) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.phoneOtpExpired ? Colors.red.shade50 : (widget.phoneSecondsLeft <= 30 ? Colors.orange.shade50 : Colors.green.shade50),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.phoneOtpExpired ? Colors.red.shade300 : (widget.phoneSecondsLeft <= 30 ? Colors.orange.shade300 : Colors.green.shade300))),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            Icon(widget.phoneOtpExpired ? Icons.timer_off : Icons.timer_outlined, size: 16,
                              color: widget.phoneOtpExpired ? Colors.red.shade700 : (widget.phoneSecondsLeft <= 30 ? Colors.orange.shade700 : Colors.green.shade700)),
                            const SizedBox(width: 6),
                            Text(widget.phoneOtpExpired ? 'Kodun süresi doldu' : 'Kalan süre: ${widget.phoneSecondsLeft} sn',
                              style: GoogleFonts.outfit(
                                color: widget.phoneOtpExpired ? Colors.red.shade700 : (widget.phoneSecondsLeft <= 30 ? Colors.orange.shade700 : Colors.green.shade700),
                                fontWeight: FontWeight.w600, fontSize: 13)),
                          ]),
                          if (widget.phoneOtpExpired)
                            GestureDetector(onTap: widget.onResetPhoneOtp,
                              child: Text('Tekrar Gönder', style: GoogleFonts.outfit(color: _kRed, fontWeight: FontWeight.w800, fontSize: 13, decoration: TextDecoration.underline, decorationColor: _kRed))),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(controller: widget.phoneOtpController, keyboardType: TextInputType.number, maxLength: 6,
                        enabled: !widget.phoneOtpExpired, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: _deco('6 Haneli SMS Kodu', Icons.sms_outlined)),
                    ],
                  ]),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
