import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'firebase_options.dart'; 
import 'dart:convert';

import 'screens/onboarding_screen.dart';
import 'services/audio/tts_service.dart';
import 'services/auth/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  
  final userBox = await Hive.openBox('user_box');
  final container = ProviderContainer();
  
  container.listen(userProfileProvider, (previous, next) {
    // Bu dinleyici, provider'ın otonom kayıt mantığını canlı tutar.
  });
  
  try {
    await container.read(ttsServiceProvider).init();
    debugPrint("🔊 TTS Motoru başarıyla uyandırıldı.");
  } catch (e) {
    debugPrint("🔊 TTS Uyandırma hatası: $e");
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); 

    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,        
      );
    } 
  } catch (e) {
    debugPrint("Firebase başlatılamadı: $e");
  }

  runApp(UncontrolledProviderScope(container: container, child: const HayatEliApp()));
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
