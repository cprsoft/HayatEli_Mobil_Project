import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/validators.dart';
import '../shared/auth_input_decoration.dart';

class SignInPhoneForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final String selectedDialCode;
  final bool otpSent;
  final bool otpExpired;
  final int secondsLeft;
  final ValueChanged<String?> onDialCodeChanged;
  final VoidCallback onResetOtp;

  const SignInPhoneForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.otpController,
    required this.selectedDialCode,
    required this.otpSent,
    required this.otpExpired,
    required this.secondsLeft,
    required this.onDialCodeChanged,
    required this.onResetOtp,
  });

  static const _kRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            enabled: !otpSent,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: authInputDecoration('Telefon Numarası', Icons.phone_outlined).copyWith(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_outlined, color: Colors.grey, size: 20),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedDialCode,
                        onChanged: onDialCodeChanged,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                        isDense: true,
                        items: Validators.dialCodes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['code'],
                            child: Text(
                              '${c['code']}',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(width: 1, height: 24, color: Colors.grey.shade300),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            validator: (v) => Validators.validatePhone(v, dialCode: selectedDialCode),
          ),

          if (otpSent) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: otpExpired ? Colors.red.shade50 : (secondsLeft <= 15 ? Colors.orange.shade50 : Colors.green.shade50),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: otpExpired ? Colors.red.shade300 : (secondsLeft <= 15 ? Colors.orange.shade300 : Colors.green.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      otpExpired ? Icons.timer_off : Icons.timer_outlined,
                      size: 16,
                      color: otpExpired ? Colors.red.shade700 : (secondsLeft <= 15 ? Colors.orange.shade700 : Colors.green.shade700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      otpExpired ? 'Kodun süresi doldu' : 'Kalan süre: $secondsLeft sn',
                      style: GoogleFonts.outfit(
                        color: otpExpired ? Colors.red.shade700 : (secondsLeft <= 15 ? Colors.orange.shade700 : Colors.green.shade700),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ]),
                  if (otpExpired)
                    GestureDetector(
                      onTap: onResetOtp,
                      child: Text(
                        'Tekrar Gönder',
                        style: GoogleFonts.outfit(color: _kRed, fontWeight: FontWeight.w800, fontSize: 13, decoration: TextDecoration.underline, decorationColor: _kRed),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              enabled: !otpExpired,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: authInputDecoration('6 Haneli SMS Kodu', Icons.sms_outlined),
            ),
            TextButton(
              onPressed: onResetOtp,
              child: Text('Farklı numara kullan', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
