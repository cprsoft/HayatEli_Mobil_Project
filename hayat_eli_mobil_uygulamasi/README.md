# HAYATELİ - Yapay Zeka Destekli Acil Durum ve İlk Yardım Mobil Uygulaması

HayatEli, acil durumlarda kullanıcıların en yakın sağlık kuruluşuna en hızlı şekilde ulaşmasını sağlayan, sesli navigasyon ve anlık SOS bildirimleri ile donatılmış hibrit bir mobil uygulama projesidir.

## 🌟 Öne Çıkan Özellikler

- **📍 Akıllı Navigasyon:** Google Maps ve Directions API entegrasyonu ile en yakın hastane ve nöbetçi eczanelere gerçek zamanlı rota çizimi.
- **🎙️ Sesli Asistan:** Google Cloud TTS desteği ile eller serbest navigasyon ve yönlendirme.
- **🆘 SOS Bildirim Sistemi:** Tek dokunuşla acil durum kontaklarına konum bilgisi içeren SMS gönderimi.
- **🔒 Güvenli Sağlık Profili:** Kullanıcı verilerinin (TC No, tıp bilgileri vb.) AES-256 algoritması ile şifrelenerek Cloud Firestore üzerinde güvenli depolanması.
- **⚡ Sunucusuz Mimari:** Firebase altyapısı ile yüksek ölçeklenebilirlik ve düşük gecikme süresi.

## 🛠️ Teknoloji Stack

- **Frontend:** Flutter (Dart)
- **Durum Yönetimi:** Flutter Riverpod
- **Backend/Veritabanı:** Firebase (Auth, Firestore, Storage)
- **Haritalama:** Google Maps SDK, Directions API, Places API
- **API Entegrasyonları:** Nosy API (Hastane ve Eczane verileri), Google Cloud TTS

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları takip ediniz:

### 1. Depoyu Klonlayın
```bash
git clone https://github.com/cprsoft/hayat_eli_mobil_uygulamasi.git
cd hayat_eli_mobil_uygulamasi
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. API Anahtarlarını Ayarlayın (Kritik)
Kök dizinde bir `.env` dosyası oluşturun ve aşağıdaki anahtarları kendi API keylerinizle doldurun:
```env
GOOGLE_MAPS_KEY=YOUR_GOOGLE_MAPS_API_KEY
NOSY_API_KEY=YOUR_NOSY_API_KEY
```

### 4. Firebase Yapılandırması
Firebase konsolu üzerinden oluşturduğunuz projenin yapılandırma dosyalarını ekleyin:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### 5. Uygulamayı Başlatın
```bash
flutter run
```

## Proje Mimarisi

Uygulama, **MVVM (Model-View-ViewModel)** ve servis odaklı (Service-Oriented) bir mimari prensibiyle geliştirilmiştir. 

- `lib/services/`: Harici API ve Firebase haberleşme katmanı.
- `lib/models/`: Veri yapıları ve JSON serileştirme.
- `lib/controllers/`: İş mantığı ve state yönetimi.
- `lib/screens/`: Kullanıcı arayüz ekranları.

---
**Not:** Bu proje bir bitirme çalışması kapsamında geliştirilmiştir. Gelecek fazlarda yapay zeka destekli ilkyardım asistanı ve canlı konum izleme entegrasyonları gibi özellikler getirilecektir.
