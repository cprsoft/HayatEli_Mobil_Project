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
| **Entegrasyon** | [![n8n](https://img.shields.io/badge/n8n-FF6C37?style=for-the-badge&logo=n8n&logoColor=white)](https://n8n.io) [![EmailJS](https://img.shields.io/badge/EmailJS-gray?style=for-the-badge)](https://www.emailjs.com) |

---

## 🔄 Proje İş Akışı (Workflow)

HayatEli platformunun modülleri arasındaki temel işleyiş ve veri akış süreçleri şu şekildedir:

*   **Kullanıcı Girişi ve Profil Yönetimi:** Kullanıcılar e-posta ve SMS tabanlı iki aşamalı doğrulama (OTP) ile giriş yapar. Kullanıcının kronik hastalık, ilaç ve alerji bilgileri gibi kritik sağlık verileri güvenli şifreleme protokolleri ile hem yerel cihaz hafızasında (Hive) hem de bulut veritabanında (Firestore) senkronize olarak tutulur.
*   **Acil Durum (SOS) ve Canlı Rota Takibi:** Kullanıcı SOS butonunu tetiklediğinde, önceden belirlenen acil durum yakınlarına konum bağlantısı içeren SMS gönderilir. Aynı zamanda konum verileri şifrelenerek arka planda n8n webhook servisine aktarılır ve yakınlarının kullanıcının rotasını canlı harita üzerinden güvenle takip etmesi sağlanır.
*   **Yapay Zeka Destekli İlk Yardım Asistanı:** Kullanıcı sesli (mikrofon) veya yazılı olarak ilk yardım sorusu sorduğunda, kullanıcının profili (alerjileri/hastalıkları) soru bağlamına otomatik olarak enjekte edilir. Güvenlik filtrelerinden geçen sorgu, yerel dil modeli (Llama 3.1) tarafından işlenerek yanıt üretilir. Yanıt arayüzde sesli olarak okunurken (TTS), ilk yardım adımları ekranda sırayla vurgulanarak gösterilir.

---

## 🌟 Öne Çıkan Özellikler

*   **📍 Akıllı Harita ve Navigasyon:** Google Maps API desteğiyle en yakın hastanelere ve nöbetçi eczanelere dinamik yol tarifi çizimi.
*   **🎙️ Eller Serbest Ses Entegrasyonu:** Entegre ses sentezi (TTS) ve mikrofon desteği ile sesli komut alımı ve interaktif ilk yardım adımları yönlendirmesi.
*   **🔒 Sıfır-Bilgi Konum Paylaşımı:** n8n webhook'ları üzerinden uçtan uca şifrelenmiş canlı rota takibi.
*   **🧠 Profil Duyarlı Yapay Zeka:** Yerel koşturulan yapay zeka asistanının, kullanıcının alerji durumuna göre ilk yardım yönergelerini dinamik olarak şekillendirmesi.
*   **📲 Çevrimdışı Çalışabilirlik:** İnternet bağlantısının olmadığı acil durumlarda yerel veritabanı sayesinde kullanıcı profilinin ve ilk yardım kılavuzunun kesintisiz çalışması.

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

### 3. API Anahtarlarını Ayarlayın
Kök dizinde bir `.env` dosyası oluşturun ve aşağıdaki şablonu kendi anahtarlarınızla doldurun:
```env
GOOGLE_MAPS_KEY=YOUR_GOOGLE_MAPS_API_KEY
NOSY_API_KEY=YOUR_NOSY_API_KEY
EMAILJS_SERVICE_ID=YOUR_EMAILJS_SERVICE_ID
EMAILJS_TEMPLATE_ID=YOUR_EMAILJS_TEMPLATE_ID
EMAILJS_PUBLIC_KEY=YOUR_EMAILJS_PUBLIC_KEY
```

### 4. Arka Uç Yapay Zeka Servisini Çalıştırma (FastAPI & Ollama)
Yapay zeka asistanının çalışabilmesi için yerel API sunucusunun ayağa kaldırılması gerekmektedir:

1.  **Ollama Kurulumu:** Bilgisayarınıza [Ollama](https://ollama.com) uygulamasını kurun.
2.  **Modeli Hazırlama:** `backend_ai` klasöründeki `Modelfile` dosyasını kullanarak Llama 3.1 tabanlı ilk yardım modelini oluşturun:
    ```bash
    ollama create hayat-ai -f ./Modelfile
    ```
3.  **FastAPI Sunucusunu Başlatma:**
    ```bash
    cd backend_ai
    pip install -r requirements.txt
    python main.py
    ```

### 5. Mobil Uygulamayı Çalıştırma
```bash
flutter run
```

---

## 🔒 Veri Güvenliği ve Protokoller

*   **Veri Şifreleme:** Bulut veritabanında saklanan tüm hassas kişisel sağlık bilgileri endüstri standartlarında şifrelenerek depolanmaktadır.
*   **Güvenli Erişim:** Çift aşamalı SMS & E-Posta OTP doğrulama altyapısı ile yetkisiz erişimlerin önüne geçilir.
*   **Arka Plan Koruma:** Konum takibi ve SOS SMS gönderimi gibi kritik arka plan süreçleri yetkilendirilmiş uygulama izinleriyle güvenceye alınmıştır.

---

## 📂 Proje Mimarisi

Uygulama, **MVVM (Model-View-ViewModel)** ve servis odaklı (Service-Oriented) bir mimari prensibiyle geliştirilmiştir. 

*   `lib/services/`: Bulut entegrasyonu, harici API servisleri ve yerel veritabanı işlemleri.
*   `lib/models/`: Veri yapıları ve serileştirme modelleri.
*   `lib/controllers/`: Riverpod durum yönetimi kontrolcüleri ve iş mantığı.
*   `lib/screens/`: Flutter kullanıcı arayüz ekranları.
*   `backend_ai/`: FastAPI ve Ollama yapay zeka servis katmanı.
