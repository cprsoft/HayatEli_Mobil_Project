import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';
import 'ai_help_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'sign_in.dart';
import '../services/auth/auth_service.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

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
          ref.read(bottomNavIndexProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.redAccent, 
        unselectedItemColor: Colors.grey,    
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency), 
            label: 'Ana Menü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt), 
            label: 'İLK YARDIM AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Acil Noktalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profilim',
          ),
        ],
      ),
    );
  }
}

