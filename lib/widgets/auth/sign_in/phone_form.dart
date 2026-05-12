import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';
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
  final VoidCallback onOtpCompleted;

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
    required this.onOtpCompleted,
  });

  static const _kRed = Color(0xFFE53935);

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: _kRed),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: otpExpired ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: otpExpired ? Colors.red.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(
                      otpExpired ? Icons.timer_off : Icons.timer_outlined,
                      size: 18,
                      color: otpExpired ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      otpExpired ? 'Kodun süresi doldu' : 'Kalan süre: ${_formatTime(secondsLeft)}',
                      style: GoogleFonts.outfit(
                        color: otpExpired ? Colors.red.shade700 : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ]),
                  if (otpExpired)
                    GestureDetector(
                      onTap: onResetOtp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _kRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YENİLE',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Pinput(
              length: 6,
              controller: otpController,
              onCompleted: (_) => onOtpCompleted(),
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: _kRed, width: 2),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(color: Colors.redAccent),
                ),
              ),

              onChanged: (code) {
                if (code.length == 6) {
                  otpController.text = code;
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onResetOtp,
              child: Text('Farklı numara kullan', style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
