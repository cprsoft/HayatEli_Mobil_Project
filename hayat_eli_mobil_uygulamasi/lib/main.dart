import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart'; 

import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); 

    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else {
      // Ekranda Chrome seçeceksen kIsWeb kontrolü yapmadan AppCheck çalıştırırsan Firebase Web'de patlar.
      // Web için eklenecekse buraya webProvider parametresi konmalıdır (Örn: ReCaptchaV3Provider).
    }
  } catch (e) {
    debugPrint("Firebase başlatılamadı: $e");
  }

  runApp(const ProviderScope(child: HayatEliApp()));
}

class HayatEliApp extends StatelessWidget {
  const HayatEliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'HAYATELİ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(), 
    );
  }
}
