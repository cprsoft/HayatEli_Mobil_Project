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
Uygulama dış servislerle haberleşmek için API anahtarlarına ihtiyaç duyar. Kök dizinde bir `.env` dosyası oluşturun ve aşağıdaki şablonu doldurun:

```env
GOOGLE_MAPS_KEY=YOUR_GOOGLE_MAPS_API_KEY
NOSY_API_KEY=YOUR_NOSY_API_KEY
EMAILJS_SERVICE_ID=YOUR_EMAILJS_SERVICE_ID
EMAILJS_TEMPLATE_ID=YOUR_EMAILJS_TEMPLATE_ID
EMAILJS_PUBLIC_KEY=YOUR_EMAILJS_PUBLIC_KEY
```

#### 3.1. Google Maps API Key Nasıl Alınır?
1. [Google Cloud Console](https://console.cloud.google.com/) üzerinden bir proje oluşturun.
2. **APIs & Services > Library** kısmından şu servisleri etkinleştirin:
   - Maps SDK for Android / iOS
   - Directions API
   - Places API
3. **Credentials** sekmesinden bir API Key oluşturun.
4. **Güvenlik İçin:** Oluşturduğunuz anahtarı Google Cloud üzerinden "API Restrictions" panelinden sadece yukarıdaki servislerle kısıtlamanız şiddetle önerilir.

#### 3.2. Nosy API Key Nasıl Alınır? (Eczane Verileri)
1. [Nosy API](https://nosyapi.com/) adresine kayıt olun.
2. Panel üzerinden "Nöbetçi Eczane" ve "Hastane" servisleri için ücretsiz krediniz biterse ekstradan desteğe yazıp kredi alabilirsiniz.
3. Size verilen API Key'i `.env` dosyasındaki `NOSY_API_KEY` alanına yapıştırın.

#### 3.3. EmailJS Kurulumu (OTP Doğrulaması)
1. [EmailJS](https://www.emailjs.com/) hesabınıza giriş yapın.
2. Bir **Email Service** bağlayın.
3. Bir **Email Template** oluşturun. Mesaj gövdesinde şu değişkenlerin bulunduğundan emin olun: 
   - `{{otp_code}}`, `{{user_email}}`, `{{time}}`
4. Account sekmesinden **Public Key**'i, Service sekmesinden **Service ID**'yi ve Template sekmesinden **Template ID**'yi alarak `.env` dosyasına kaydedin.

### 4. Firebase Yapılandırması
1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni bir proje oluşturun.
2. Android ve iOS uygulamalarını projeye ekleyin.
3. Yapılandırma dosyalarını projenize yerleştirin:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. `lib/firebase_options.dart` dosyası FlutterFire CLI tarafından oluşturulacaktır. İçerideki `apiKey` değerleri istemci tarafı tanımlayıcılardır; ancak güvenliği artırmak için Firebase Console üzerinden **App Check** özelliğini aktif etmeniz önerilir.

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
