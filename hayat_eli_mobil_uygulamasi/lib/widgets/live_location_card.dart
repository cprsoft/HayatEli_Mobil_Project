import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

class LiveLocationCard extends ConsumerWidget {
  const LiveLocationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          
          // Duruma göre metin gösterimi
          if (locationState.isLoading)
            const Text(
              "Konum Aranıyor...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )
          else if (locationState.error != null)
            Text(
              locationState.error!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
              textAlign: TextAlign.center,
            )
          else
            Text(
              locationState.address ?? "Bilinmeyen Konum",
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15,
                color: Color(0xFFB71C1C), // Kan kırmızısı
              ),
              textAlign: TextAlign.center,
            ),
            
          if (locationState.isLoading && locationState.error == null) ...[
            const SizedBox(height: 4),
            const Text(
              "112'ye bildirmek için adresiniz saptanıyor",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
