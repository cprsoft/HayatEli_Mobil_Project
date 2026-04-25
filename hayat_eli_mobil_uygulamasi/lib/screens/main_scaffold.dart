import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import 'ai_help_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'sign_in.dart';
import '../services/auth_service.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  void _showRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.red),
              SizedBox(width: 10),
              Text("Kilitli Özellik", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            "Acil Noktalar ve Profilim özelliklerini kullanabilmek için lütfen ücretsiz kayıt olun veya giriş yapın.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              child: const Text("Kayıt Ol / Giriş Yap", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final authState = ref.watch(authStateProvider);
    final isGuest = authState.when(
      data: (user) => user == null,
      loading: () => true,
      error: (_, __) => true,
    );

    final List<Widget> screens = [
      const HomeScreen(),    
      const AiHelpScreen(),  
      const MapScreen(),     
      const ProfileScreen(), 
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if ((index == 2 || index == 3) && isGuest) {
            _showRegistrationDialog(context); 
            return; 
          }
          ref.read(bottomNavIndexProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.redAccent, 
        unselectedItemColor: Colors.grey,    
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.emergency), 
            label: 'Ana Menü',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt), 
            label: 'İLK YARDIM AI',
          ),
        
          BottomNavigationBarItem(
            icon: Icon(isGuest ? Icons.lock_outline : Icons.map_outlined),
            activeIcon: Icon(isGuest ? Icons.lock : Icons.map),
            label: 'Acil Noktalar',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(isGuest ? Icons.lock_outline : Icons.person_outline),
            activeIcon: Icon(isGuest ? Icons.lock : Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}
