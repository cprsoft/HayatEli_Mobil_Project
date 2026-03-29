import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _resetPassword() {
    final email = _emailController.text.trim();
    ref.read(forgotPasswordControllerProvider.notifier).sendPasswordReset(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.isSuccess && (previous == null || !previous.isSuccess)) {
        _emailController.clear();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Şifrenizi mi Unuttunuz?',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB71C1C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Kayıtlı e-posta adresinizi girin, size şifrenizi sıfırlamanız için bir bağlantı gönderelim.',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              if (state.message != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: state.isError ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isError ? Colors.red.shade300 : Colors.green.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.isError ? Icons.error_outline : Icons.check_circle_outline,
                        color: state.isError ? Colors.red : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.message!,
                          style: GoogleFonts.outfit(
                            color: state.isError ? Colors.red.shade700 : Colors.green.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Sıfırlama Bağlantısı Gönder',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
