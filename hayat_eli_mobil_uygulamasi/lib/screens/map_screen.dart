import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; // GPS Eklentisi eklendi

import '../utils/city_data.dart';
import '../services/hospital_api_service.dart';
import '../services/nobetci_eczane_api.dart';
import 'route_map_screen.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  bool isHospitalSelected = true;
  
  // Combobox Durum Yönetimi
  String? _selectedCity;
  String? _selectedDistrict;

  // Arama Durum Yönetimi
  bool _isLoading = false;
  bool _hasSearched = false;
  List<dynamic> _placesList = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Slug Çevirici Metot (Örn: "Şanlıurfa" -> "sanliurfa")
  String _toSlug(String text) {
    return text
        .replaceAll('I', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('Ç', 'c')
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .toLowerCase()
        .replaceAll(' ', '-');
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Sayfayı Yukarıdan Çekerek Yenileme (Pull-to-Refresh / Reset)
  Future<void> _onRefresh() async {
    setState(() {
      _selectedCity = null;
      _selectedDistrict = null;
      _placesList = [];
      _hasSearched = false;
      isHospitalSelected = true;
      _isLoading = false;
    });
    // Kısacık bir bekleme süresi, pürüzsüz UX sağlar.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // API Sorgulama Metodu
  Future<void> _searchPlaces() async {
    if (_selectedCity == null) return;
    
    setState(() => _isLoading = true);

    final citySlug = _toSlug(_selectedCity!);
    final districtSlug = _selectedDistrict != null ? _toSlug(_selectedDistrict!) : null;

    List<dynamic>? results;

    if (isHospitalSelected) {
      final service = HospitalApiService();
      results = await service.getHospitals(citySlug: citySlug, districtSlug: districtSlug);
    } else {
      final service = NobetciEczaneApi();
      results = await service.getPharmacies(citySlug: citySlug, districtSlug: districtSlug);
    }

    setState(() {
      _hasSearched = true;
      if (results != null) {
        _placesList = results;
        // İlçe seçilmemişse alfabetik sıraya (isimlerine göre) (A-Z) diziyoruz
        if (_selectedDistrict == null) {
          _placesList.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        }
      } else {
        _placesList = [];
      }
      _isLoading = false;
    });
  }

  // En Yakın Noktayı Bulma Metodu (GPS tabanlı)
  Future<void> _findNearest() async {
    setState(() => _isLoading = true);

    try {
      // 1. GPS Servisi açık mı kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Lütfen cihazınızın Konum (GPS) servisini açın.")));
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. İzinler verilmiş mi kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Konum izni reddedilmiş. Ayarlardan açmanız gerekiyor.")));
        }
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // 3. Google tahminlerini değil donanımsal çipi (GPS) zorlayarak en iyi doğruluğu al.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        forceAndroidLocationManager: true, // Baz istasyonu yamalarını pas geçip net uydu bağını ara.
        timeLimit: const Duration(seconds: 15),
      );

      List<dynamic>? results;

      if (isHospitalSelected) {
        final service = HospitalApiService();
        results = await service.getHospitalsByLocation(latitude: position.latitude, longitude: position.longitude);
      } else {
        final service = NobetciEczaneApi();
        results = await service.getPharmaciesByLocation(latitude: position.latitude, longitude: position.longitude);
      }

      if (mounted) {
        setState(() {
          _hasSearched = true;
          if (results != null) {
            _placesList = results.take(5).toList(); // En yakın olan 5 kayıt
          } else {
            _placesList = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum alınamadı/İstek başarısız: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF2121),
          backgroundColor: Colors.white,
          onRefresh: _onRefresh, // Çek-bırak sıfırlama mekanizması
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // ÜST VE FİLTRELEME KISMI
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildPremiumSegmentedControl(),
                    const SizedBox(height: 16),
                    _buildFilterSection(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              
              // LİSTE KISMI (Padding eklendiği için BottomNavBar'ın altında kalmayacak)
              _buildPlacesList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- PREMIUM NAVBAR (IOS Style Floating Pill) ---
  Widget _buildPremiumSegmentedControl() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Kayan Kan Kırmızısı Arka Plan
          AnimatedAlign(
            alignment: isHospitalSelected ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3B30), Color(0xFF990000)], // Damarlardan akan kan kırmızısı
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF990000).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
              ),
            ),
          ),
          
          // Tıklanabilir Butonlar
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        isHospitalSelected = true;
                        _searchPlaces(); 
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('lib/assets/images/hastane.png', width: 22, height: 22, 
                            errorBuilder: (ctx, err, stack) => Icon(Icons.local_hospital_rounded, 
                              color: isHospitalSelected ? Colors.white : Colors.grey.shade500, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Hastane",
                            style: GoogleFonts.outfit(
                              fontWeight: isHospitalSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                              color: isHospitalSelected ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        isHospitalSelected = false;
                        _placesList = []; 
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('lib/assets/images/eczane.png', width: 22, height: 22,
                            errorBuilder: (ctx, err, stack) => Icon(Icons.local_pharmacy_rounded, 
                              color: !isHospitalSelected ? Colors.white : Colors.grey.shade500, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Nöbetçi Eczane", 
                            style: GoogleFonts.outfit(
                              fontWeight: !isHospitalSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13, // Sığması için 13 yapıldı
                              color: !isHospitalSelected ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            // Sol Taraf: Filtre Combobox'ları
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCityDropdown(),
                  const SizedBox(height: 12),
                  _buildDistrictDropdown(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Sağ Taraf: Sorgula ve En Yakın Bul Butonları
            SizedBox(
              width: 90,
              height: 100, // 2 Combobox yüksekliği
              child: Column(
                children: [
                  // Sorgula Butonu (Üst) -> Yeşil
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedCity != null) {
                          _searchPlaces();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF009624)], // Yeşil tonları
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF009624).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                            const SizedBox(height: 2),
                            Text("Sorgula", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 2), // Araya ince bir çizgi boşluğu
                  
                  // En Yakın Hastane Butonu (Alt) -> Kan Kırmızısı
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _findNearest();
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isHospitalSelected 
                                ? const [Color(0xFFFF3B30), Color(0xFF990000)] // Koyu Damar Kırmızısı
                                : const [Color(0xFFFF5252), Color(0xFFC62828)], // Daha Açık Eczane Kırmızısı
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: isHospitalSelected 
                                  ? const Color(0xFF990000).withOpacity(0.3)
                                  : const Color(0xFFC62828).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isHospitalSelected ? Icons.my_location_rounded : Icons.local_pharmacy_rounded, color: Colors.white, size: 16),
                            Text(isHospitalSelected ? "En Yakın\nHastane" : "En Yakın\nEczane", 
                              textAlign: TextAlign.center, 
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            "📍 Şehir Seçiniz",
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          value: _selectedCity,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.redAccent.shade100, size: 24),
          items: CityData.cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedDistrict = null; // İl değişince ilçeyi sıfırla
            });
          },
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    final List<String> districts = _selectedCity != null ? CityData.turkeyCities[_selectedCity]! : [];
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _selectedCity == null ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            "🏘️ İlçe Seçiniz",
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          value: _selectedDistrict,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400, size: 24),
          items: districts.map((district) {
            return DropdownMenuItem<String>(
              value: district,
              child: Text(district, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: _selectedCity == null
              ? null
              : (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
        ),
      ),
    );
  }

  // ALT PANEL (Detay Gösterimi)
  void _showPlaceDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Çekme çubuğu
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              // İsim
              Text(
                item['name'] ?? 'Bilinmeyen İstasyon',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              // İl/İlçe Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "${item['district'] ?? ''} / ${item['city'] ?? ''}",
                  style: GoogleFonts.manrope(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              // Adres
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade400, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['address'] ?? 'Adres bilgisi bulunamadı',
                      style: GoogleFonts.manrope(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Telefon
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.red.shade400, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    item['phone'] ?? 'Kayıtlı telefon numarası yok',
                    style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                ],
              ),
              
              // Nöbet Saatleri (Sadece Eczane)
              if (!isHospitalSelected && item['pharmacyDutyStart'] != null && item['pharmacyDutyEnd'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded, color: Colors.red.shade400, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Nöbet Saati: ${item['pharmacyDutyStart']} - ${item['pharmacyDutyEnd']}",
                          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                
              // Ekstra Telefon (Sadece Eczane ve dolu ise)
              if (!isHospitalSelected && item['phone2'] != null && item['phone2'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.phone_rounded, color: Colors.red.shade400, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        item['phone2'].toString(),
                        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                
              // Yol Tarifi / Tarif Notu (Sadece Eczane ve dolu ise)
              if (!isHospitalSelected && item['directions'] != null && item['directions'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.blue.shade500, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Açıklama: ${item['directions']}",
                          style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
              // Rota Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteMapScreen(
                          targetName: item['name'] ?? 'Bilinmeyen Nokta',
                          targetLat: double.tryParse(item['latitude'].toString()) ?? 0.0,
                          targetLng: double.tryParse(item['longitude'].toString()) ?? 0.0,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: Text('Yol Tarifi Al', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlacesList() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
        ),
      );
    }

    if (_placesList.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 16, right: 16),
          child: Center(
            child: Text(
              _hasSearched 
                  ? (isHospitalSelected 
                      ? "Aradığınız kriterlere uygun\nhastane bulunamadı."
                      : "Aradığınız kriterlere uygun\nnöbetçi eczane bulunamadı.")
                  : "Aramaya başlamak için Şehir\nve (isteğe bağlı) İlçe seçin.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: _hasSearched ? Colors.red.shade400 : Colors.grey.shade500, 
                fontSize: 16,
                fontWeight: _hasSearched ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      // Alt kısımdan 100 pingellik boşluk bırakıyoruz ki BottomNavBar'ın altında kalmasın.
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 100),
      sliver: SliverList.builder(
        itemCount: _placesList.length,
        itemBuilder: (context, index) {
        final item = _placesList[index];
        // En Yakın API'den dönen location cevabında distanceMt var. "Sorgula" cevabında yok.
        final bool isClosest = item['distanceMt'] != null && index == 0; 
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isClosest ? const Color(0xFFFF4B4B).withOpacity(0.4) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isClosest ? const Color(0xFFFF4B4B).withOpacity(0.15) : Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: GestureDetector(
            onTap: () => _showPlaceDetails(item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isClosest)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                    ),
                    child: Row(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: const Icon(Icons.favorite, color: Color(0xFFFF2121), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Şu an sana en yakın ve hızlı konum",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF2121),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Sol İkon (Resim Dosyası Ne İse O)
                    Image.asset(
                      isHospitalSelected ? 'lib/assets/images/hastane_ikon.png' : 'lib/assets/images/eczane_ikon.jpg',
                      height: 64,
                      width: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 64, 
                        width: 64, 
                        color: isHospitalSelected ? Colors.blue.shade400 : Colors.teal, 
                        child: Icon(
                          isHospitalSelected ? Icons.local_hospital_rounded : Icons.local_pharmacy_rounded, 
                          color: Colors.white, 
                          size: 30
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Orta Bilgiler 
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                item['distanceMt'] != null ? Icons.directions_walk_rounded : Icons.location_on_rounded, 
                                size: 16, 
                                color: Colors.grey.shade500
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item['distanceMt'] != null 
                                      ? "≈ ${item['distanceMt']} m (düz hat)"
                                      : "${item['district'] ?? ''} / ${item['city'] ?? ''}",
                                  style: GoogleFonts.outfit(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Yol Tarifi Butonu ve Altındaki Yazı
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteMapScreen(
                              targetName: item['name'] ?? 'Bilinmeyen Nokta',
                              targetLat: double.tryParse(item['latitude'].toString()) ?? 0.0,
                              targetLng: double.tryParse(item['longitude'].toString()) ?? 0.0,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: isClosest ? const Color(0xFFFF2121) : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (isClosest ? const Color(0xFFFF2121) : Colors.black).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.alt_route_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Yol Tarifi Al",
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isClosest ? const Color(0xFFFF2121) : Colors.black87,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
         ),
        );
      },
    ));
  }
}

