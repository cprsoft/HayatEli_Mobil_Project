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
import 'screens/main_scaffold.dart';
import 'services/audio/tts_service.dart';
import 'services/auth/auth_service.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  
  final userBox = await Hive.openBox('user_box');
  final bool isLoggedIn = userBox.isNotEmpty;
  
  final container = ProviderContainer();
  
  container.listen(userProfileProvider, (previous, next) {});
  
  try {
    await container.read(ttsServiceProvider).initialize();
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

  runApp(UncontrolledProviderScope(container: container, child: HayatEliApp(isLoggedIn: isLoggedIn)));
}

class HayatEliApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const HayatEliApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'HAYATELİ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainScaffold() : const OnboardingScreen(), 
    );
  }
}
