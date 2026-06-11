import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/crash_alert_screen.dart';

class CustomSosButton extends ConsumerStatefulWidget {
  const CustomSosButton({super.key});

  @override
  ConsumerState<CustomSosButton> createState() => _CustomSosButtonState();
}

class _CustomSosButtonState extends ConsumerState<CustomSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CrashAlertScreen()),
          );
        },
        child: Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFFB71C1C).withValues(alpha: 0.15),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "112 ACİL",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.phone_in_talk,
                  color: Colors.white,
                  size: 52,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
