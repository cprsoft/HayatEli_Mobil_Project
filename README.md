# 🏥 HAYATELİ - Yapay Zeka Destekli Acil Durum ve İlk Yardım Mobil Uygulaması

HayatEli; acil durumlarda hayat kurtarıcı müdahaleleri hızlandırmak, kullanıcıyı en doğru sağlık kuruluşuna yönlendirmek, yerel yapay zeka ile ilk yardım talimatları sağlamak ve güvenli canlı konum paylaşımı sunmak amacıyla geliştirilmiş hibrit bir mobil yardım platformudur.

---

## 📌 İçindekiler
- [🛠️ Teknoloji Stack](#️-teknoloji-stack)
- [🔄 Proje İş Akışı (Workflow)](#-proje-iş-akışı-workflow)
- [🌟 Öne Çıkan Özellikler](#-öne-çıkan-özellikler)
- [🚀 Kurulum ve Çalıştırma](#-kurulum-ve-çalıştırma)
- [🔒 Veri Güvenliği ve Protokoller](#-veri-güvenliği-ve-protokoller)
- [📂 Proje Mimarisi](#-proje-mimarisi)

---

## 🛠️ Teknoloji Stack

Uygulamanın geliştirilmesinde kullanılan teknolojiler, diller ve kütüphaneler aşağıda tıklanabilir rozetler halinde listelenmiştir:

| Katman | Kullanılan Teknolojiler |
| :--- | :--- |
| **Frontend** | [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=Dart&logoColor=white)](https://dart.dev) |
| **Durum Yönetimi** | [![Riverpod](https://img.shields.io/badge/Riverpod-%234C51BF.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev) |
| **Veritabanı & Bulut** | [![Firebase](https://img.shields.io/badge/Firebase-%23FFCA28.svg?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com) [![Hive](https://img.shields.io/badge/Hive_NoSQL-orange?style=for-the-badge)](https://pub.dev/packages/hive) |
| **Yapay Zeka API** | [![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com) [![Ollama](https://img.shields.io/badge/Ollama-black?style=for-the-badge)](https://ollama.com) |
| **Haritalama** | [![Google Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)](https://developers.google.com/maps) |
| **Entegrasyon** | [![EmailJS](https://img.shields.io/badge/EmailJS-gray?style=for-the-badge)](https://www.emailjs.com) |

---

## 🔄 Proje İş Akışı (Workflow)

HayatEli platformunun modülleri arasındaki temel işleyiş ve veri akış süreçleri şu şekildedir:

<!-- *(Eğer hazırladığınız görsel bir iş akış şeması varsa, aşağıdaki görsel alanını kullanabilirsiniz)*
![HayatEli Sistem İş Akışı](docs/images/workflow.png) -->

*   **Kullanıcı Girişi ve Profil Yönetimi:** Kullanıcılar e-posta ve SMS tabanlı iki aşamalı doğrulama (OTP) ile giriş yapar. Kullanıcının kronik hastalık, ilaç ve alerji bilgileri gibi kritik sağlık verileri güvenli şifreleme protokolleri ile hem yerel cihaz hafızasında (Hive) hem de bulut veritabanında (Firestore) senkronize olarak tutulur.
*   **Acil Durum (SOS) Tetikleme ve İhbar Akışı:** Kullanıcı acil bir durumda ana ekrandaki **SOS butonuna 3 saniye basılı tuttuğunda** yüksek sesli bir siren çalar ve önceden belirlenen acil durum yakınlarına otomatik olarak harita konum bağlantısı içeren yardım SMS'i gönderilir.
*   **Canlı Rota Takibi:** SOS tetiklendiği andan itibaren kullanıcının canlı GPS koordinatları şifrelenerek Firebase Firestore gerçek zamanlı veritabanına aktarılır. Yakınları, kendilerine gelen SMS'teki bağlantıya tıklayarak kullanıcının hareketlerini web paneli üzerinden canlı haritada anlık takip eder.
*   **Yapay Zeka Destekli İlk Yardım Asistanı (Hayat AI):** Kullanıcı sesli (mikrofon) veya yazılı olarak ilk yardım sorusu sorduğunda, kullanıcının profili (alerjileri/hastalıkları) soru bağlamına otomatik olarak enjekte edilir. Güvenlik filtrelerinden geçen sorgu, yerel dil modeli (Llama 3.1) tarafından işlenerek yanıt üretilir. Yanıt arayüzde sesli olarak okunurken (TTS), ilk yardım adımları ekranda sırayla vurgulanarak gösterilir.

---

## 🌟 Öne Çıkan Özellikler

*   **🆘 Akıllı SOS Butonu & Siren Sistemi:** Panik anında yanlışlıkla basılmasını önlemek amacıyla 3 saniye basılı tutma kuralına bağlı çalışan, sesli siren çalan ve yakınlara anında acil durum konum SMS'i atan akıllı SOS modülü.
*   **📚 İnteraktif İlk Yardım Rehberi:** Bebek, çocuk ve yetişkin kategorilerine ayrılmış; internet olmasa dahi çevrimdışı (offline) çalışabilen, adımları sesli okuyan ve ilgili adımı ekranda otomatik vurgulayarak kaydıran interaktif rehber.
*   **🧠 Profil Duyarlı Yapay Zeka (Hayat AI):** Yerel koşturulan yapay zeka asistanının, kullanıcının alerji durumuna göre ilk yardım yönergelerini dinamik olarak şekillendirmesi (örn. penisilin veya arı sokması uyarısı).
*   **📍 Akıllı Harita ve Navigasyon:** Google Maps API desteğiyle en yakın hastanelere ve nöbetçi eczanelere dinamik yol tarifi çizimi.
*   **🎙️ Eller Serbest Ses Entegrasyonu:** Entegre ses sentezi (TTS) ve mikrofon desteği ile sesli komut alımı ve interaktif ilk yardım adımları yönlendirmesi.
*   **🔒 Sıfır-Bilgi Konum Paylaşımı:** Firebase Firestore gerçek zamanlı veri akışı üzerinden şifrelenmiş canlı rota takibi.

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları takip ediniz:

### 1. Depoyu Klonlayın
```bash
git clone https://github.com/cprsoft/HayatEli_Mobil_Project.git
cd HayatEli_Mobil_Project
```

### 2. Mobil Proje Bağımlılıklarını Yükleyin
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

### 5. Arka Uç Yapay Zeka Servisini Çalıştırma (FastAPI & Ollama)
Yapay zeka asistanının çalışabilmesi için yerel API sunucusunun ayağa kaldırılması gerekmektedir:

1.  **Ollama Kurulumu:** Bilgisayarınıza [Ollama](https://ollama.com) uygulamasını kurun.
2.  **Model Dosyasını Temin Etme (2 Seçenek):**
    *   **Seçenek A (Önerilen - Manuel İndirme):** [HuggingFace - Llama 3.1 8B Instruct Q4_K_M](https://huggingface.co/Bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf) adresinden GGUF dosyasını indirin ve `backend_ai` klasörünün içine yerleştirin.
    *   **Seçenek B (Alternatif - Otomatik İndirme):** `backend_ai/Modelfile` dosyasını açın ve 2. satırı `FROM llama3.1` olarak değiştirin (Ollama modeli kütüphaneden kendisi çekecektir).
3.  **Modeli Hazırlama:** `backend_ai` klasöründe şu komutu çalıştırarak ilk yardım modelini derleyin:
    ```bash
    ollama create hayat-ai -f ./Modelfile
    ```
4.  **FastAPI Sunucusunu Başlatma:**
    ```bash
    cd backend_ai
    pip install -r requirements.txt
    python main.py
    ```

### 6. Mobil Uygulamayı Çalıştırma
```bash
flutter run
```

---

## 🔒 Veri Güvenliği ve Protokoller

*   **Veri Şifreleme:** Bulut veritabanında saklanan tüm hassas kişisel sağlık bilgileri endüstri standartlarında şifrelenerek depolanmaktadır.
*   **Güvenli Erişim:** Çift aşamalı SMS & E-Posta OTP doğrulama altyapısı ile yetcisiz erişimlerin önüne geçilir.
*   **Arka Plan Koruma:** Konum takibi ve SOS SMS gönderimi gibi kritik arka plan süreçleri yetkilendirilmiş uygulama izinleriyle güvenceye alınmıştır.

---

## 📂 Proje Mimarisi

Uygulama, **MVVM (Model-View-ViewModel)** ve servis odaklı (Service-Oriented) bir mimari prensibiyle geliştirilmiştir. 

*   `lib/services/`: Bulut entegrasyonu, harici API servisleri ve yerel veritabanı işlemleri.
*   `lib/models/`: Veri yapıları ve serileştirme modelleri.
*   `lib/controllers/`: Riverpod durum yönetimi kontrolcüleri ve iş mantığı.
*   `lib/screens/`: Flutter kullanıcı arayüz ekranları.
*   `backend_ai/`: FastAPI ve Ollama yapay zeka servis katmanı.
