import 'package:flutter/material.dart';

class FirstAidTopic {
  final String id;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> keywords;
  final IconData icon;
  final List<Color> gradientColors;
  final String? personalizedWarningKey;
  final String? imageUrl;
  final List<String>? stepImageUrls;
  final List<String>? symptoms;
  final List<String>? warnings;

  const FirstAidTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.keywords,
    required this.icon,
    required this.gradientColors,
    this.personalizedWarningKey,
    this.imageUrl,
    this.stepImageUrls,
    this.symptoms,
    this.warnings,
  });
}

class FirstAidSubGroup {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<FirstAidTopic> topics;

  const FirstAidSubGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.topics,
  });
}

class FirstAidCategoryItem {
  final FirstAidTopic? topic;
  final FirstAidSubGroup? subGroup;

  const FirstAidCategoryItem({this.topic, this.subGroup})
      : assert(topic != null || subGroup != null);

  bool get isSubGroup => subGroup != null;
}

class FirstAidCategory {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<FirstAidCategoryItem> items;

  const FirstAidCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.items,
  });
}

const List<FirstAidCategory> firstAidGuideData = [
  FirstAidCategory(
    title: "Genel İlkyardım Bilgileri",
    description:
        "İlkyardımın tanımı, KBK ilkeleri, 112 araması ve ilkyardımın ABC'si",
    icon: Icons.health_and_safety_rounded,
    gradientColors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "general_first_aid",
          title: "İlkyardım ve KBK İlkeleri",
          description:
              "İlkyardımın tanımı, acil tedavi farkı ve Koruma, Bildirme, Kurtarma (KBK) uygulamaları.",
          keywords: [
            "ilkyardım",
            "acil",
            "kbk",
            "koruma",
            "bildirme",
            "kurtarma",
            "112"
          ],
          icon: Icons.info_outline_rounded,
          gradientColors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
          imageUrl: "lib/assets/images/ilkyardim-egitim.jpg",
          symptoms: [
            "**İlkyardım:** Kaza veya yaşamı tehlikeye düşüren durumda, sağlık görevlilerinin yardımı sağlanıncaya kadar, tıbbi araç gereç aranmaksızın mevcut araçlarla yapılan **ilaçsız** uygulamalardır.",
            "**Acil Tedavi:** Doktor ve sağlık personeli tarafından yapılan **tıbbi** müdahalelerdir.",
            "**İlkyardımcı:** Tıbbi araç gereç aramaksızın mevcut imkanlarla ilaçsız uygulamaları yapan **eğitim almış** kişidir.",
            "**Öncelikli Amaçlar:** Hayati tehlikeyi ortadan kaldırmak, yaşamsal fonksiyonları sürdürmek, kötüleşmeyi önlemek ve iyileşmeyi kolaylaştırmak."
          ],
          warnings: [
            "⚠️ **Telefonu Kapatmayın:** 112 hattındaki görevli tüm bilgileri aldığını söyleyip kapatabileceğini belirtmeden telefonu KESİNLİKLE kapatmayın.",
            "⚠️ **Kıpırdatmayın:** Ağır hasta/yaralı bir kişi hayati bir tehlike (yangın, patlama vb.) olmadığı sürece KESİNLİKLE yerinden kıpırdatılmamalıdır."
          ],
          steps: [
            "**Koruma (Olay Yeri Güvenliği):** Kaza sonuçlarının ağırlaşmasını önlemek için olay yerinde oluşabilecek tehlikeleri belirleyin ve güvenli bir çevre oluşturun.",
            "**Bildirme (112 Arama):** Hızlıca 112'yi arayın. Sakin olun, adres bilgilerini net verin, yaralı sayısını ve durumlarını bildirin.",
            "**Kurtarma (Müdahale):** Yaralılara hızlı ama sakin müdahale edin. Kırıklara yerinde müdahale edin, yaralıyı sıcak tutun ve yarasını görmesine izin vermeyin."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "first_aid_abc",
          title: "Hayat Kurtarma Zinciri ve ABC",
          description:
              "Hayat kurtarma zincirinin 4 halkası ve yaşamsal değerlendirmede ilkyardımın ABC'si.",
          keywords: [
            "zincir",
            "abc",
            "havayolu",
            "solunum",
            "dolaşım",
            "nabız",
            "değerlendirme"
          ],
          icon: Icons.analytics_outlined,
          gradientColors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
          symptoms: [
            "**Bilinç Durumu:** Bilinç kapalı ise yaşamsal refleksler ve fonksiyonlar hemen değerlendirilmelidir.",
            "**Solunum (B):** Göğüs kafesinin hareket etmesi, solunum sesi ve yanağımıza gelen sıcaklık ile anlaşılır.",
            "**Dolaşım (C):** Şah damarındaki nabız atımları ile kontrol edilir."
          ],
          warnings: [
            "⚠️ **10 Saniye Kuralı:** Solunumu değerlendirirken (Bak-Dinle-Hisset) süresinin tam 10 saniye olmasına dikkat edin.",
            "⚠️ **Dolaşım Süresi:** Nabız kontrolünü şah damarından tam 5 saniye boyunca hissederek yapın.",
            "⚠️ **Zincir Sınırı:** Hayat kurtarma zincirinin 3. ve 4. halkası (Ambulans ve Hastane müdahalesi) ileri yaşam desteğidir, ilkyardımcının görevi değildir."
          ],
          steps: [
            "**1. Halka - Sağlık Kuruluşuna Haber Verilmesi:** Olay anında hızlıca 112 Acil Çağrı Merkezi aranmalı veya bir başkasına aratılmalıdır.",
            "**2. Halka - Olay Yerinde Temel Yaşam Desteği:** İlkyardım eğitimi almış kişiler tarafından zaman kaybetmeden kalp masajı ve yapay solunum (CPR) başlatılmalıdır.",
            "**3. Halka - Ambulans Ekiplerince Müdahale:** Olay yerine ulaşan acil sağlık personeli tarafından yapılan profesyonel tıbbi müdahaledir (İleri yaşam desteğidir, ilkyardımcının görevi değildir).",
            "**4. Halka - Hastane Acil Servisinde Müdahale:** Hastaneye ulaştırılan kazazedenin acil servis ünitelerinde uzman hekimlerce tedavi edilmesidir (İleri yaşam desteğidir, ilkyardımcının görevi değildir)."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Hasta/Yaralı ve Olay Yerinin Değerlendirilmesi",
    description:
        "Bilinç seviyeleri, yaşam bulguları, vücut sistemleri, baştan aşağı muayene ve olay yeri güvenliği.",
    icon: Icons.manage_search_rounded,
    gradientColors: [Color(0xFF00AD87), Color(0xFF00796B)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "body_systems_and_vitals",
          title: "İnsan Vücudu ve Yaşam Bulguları",
          description:
              "İlkyardımda bilinmesi gereken vücut sistemleri ve bilinç, solunum, nabız, vücut ısısı gibi hayati göstergeler.",
          keywords: [
            "vücut",
            "sistemler",
            "yaşam bulguları",
            "bilinç",
            "solunum sıklığı",
            "nabız",
            "vücut ısısı",
            "vital"
          ],
          icon: Icons.monitor_heart_rounded,
          gradientColors: [Color(0xFF26A69A), Color(0xFF00796B)],
          stepImageUrls: [
            "lib/assets/images/hareket.jpg",
            "lib/assets/images/dolasim.jpg",
            "lib/assets/images/sinir.jpg",
            "lib/assets/images/solunum.jpg",
            "lib/assets/images/bosaltim.jpg",
            "lib/assets/images/sindirim.jpg",
          ],
          symptoms: [
            "**Bilinç Seviyeleri:** Bilinci yerinde olanlar tüm uyarılara cevap verir. 1. derece (sözlü), 2. derece (ağrılı) uyarılara cevap verir. 3. derece ise tamamen tepkisizdir.",
            "**Normal Solunum Sayısı (1 dk):** Yetişkinlerde 12-20, çocuklarda 16-22, bebeklerde 18-24'tür.",
            "**Normal Nabız Sayısı (1 dk):** Yetişkinlerde 60-100, çocuklarda 100-120, bebeklerde 100-140'tır.",
            "**Vücut Isısı:** Normal değer 36.5°C'dir. 41-42°C üstü ve 34.5°C altı tehlikelidir. 31°C ve altı ölümcüldür."
          ],
          warnings: [
            "⚠️ **Nabız Noktaları:** Çocuk ve yetişkinlerde dolaşım kontrolü şah damarından, bebeklerde ise kol atardamarından yapılır.",
            "⚠️ **Tansiyon:** Olay yerinde ilkyardımcı tarafından kan basıncı (tansiyon) kontrol edilmez.",
            "⚠️ **Isı Ölçümü:** İlkyardımda vücut ısısı her zaman koltuk altından ölçülmelidir."
          ],
          steps: [
            "**Hareket Sistemi:** Kemikler, eklemler ve kaslardan oluşur. Vücudun hareket etmesini, desteklenmesini sağlar ve koruyucu görev yapar.",
            "**Dolaşım Sistemi:** Kalp, kan damarları ve kandan oluşur. Vücut dokularına oksijen, besin, hormon taşır ve atıkları geri toplar.",
            "**Sinir Sistemi:** Beyin, beyincik, omurilik ve omurilik soğanından oluşur. Bilinç, algı, solunum ve dolaşım uyumunu sağlar.",
            "**Solunum Sistemi:** Solunum yolları ve akciğerlerden oluşur. Vücuda gerekli gaz alışverişini yaparak dokuların oksijenlenmesini sağlar.",
            "**Boşaltım Sistemi:** Böbrekler, idrar yolları ve idrar kesesinden oluşur. Kanı süzüp zararlı maddeleri atarak iç dengeyi korur.",
            "**Sindirim Sistemi:** Dil, dişler, yemek borusu, mide ve bağırsaklardan oluşur. Besinleri sindirip kana karışmasını sağlar."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "patient_evaluation",
          title: "Hasta/Yaralının Değerlendirilmesi",
          description:
              "Bilinç ve ABC değerlendirmesi (Havayolu, Solunum, Dolaşım) ile baştan aşağı detaylı muayene adımları.",
          keywords: [
            "muayene",
            "değerlendirme",
            "bilinç",
            "havayolu",
            "solunum",
            "dolaşım",
            "abc",
            "baştan aşağı",
            "fiziksel"
          ],
          icon: Icons.person_search_rounded,
          gradientColors: [Color(0xFF00AD87), Color(0xFF00796B)],
          symptoms: [
            "**İlk Muayene Amacı:** Hastalık/yaralanmanın ciddiyetini anlamak, öncelikleri belirlemek ve güvenli müdahale yöntemi seçmek.",
            "**İkinci Muayene Amacı:** Yaşam bulgularını güvenceye aldıktan sonra gizli kırık, kanama veya baş/boyun travmalarını tespit etmek."
          ],
          warnings: [
            "⚠️ **Boyun Zedelenmesi:** Aksi ispat edilene kadar tüm travmalarda boyun zedelenmesi şüphesi göz ardı edilmemelidir.",
            "⚠️ **Cisim Çıkarma:** Vücuda saplanmış yabancı cisimler KESİNLİKLE yerinden çıkarılmamalı, hareket ettirilmeden sabitlenmelidir.",
            "⚠️ **Bilinç Kaybı:** Bilinci kapalı olan hastaya ağızdan KESİNLİKLE yiyecek, içecek veya ilaç verilmemelidir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Hastanın omzuna hafifçe dokunup 'iyi misiniz?' diye sorarak bilincini değerlendirin (Sözlü ve fiziksel uyarana cevap veriyor mu?).",
            "**Havayolu Açıklığı (A):** Ağız içini kontrol edin, yabancı cisim varsa işaret parmağınızla yana doğru sokup çıkarın. Alından bastırıp çeneden kaldırarak Baş Geri - Çene Yukarı pozisyonu verin.",
            "**Solunum Değerlendirmesi (B):** Bak-Dinle-Hisset yöntemiyle göğüs kafesini izleyip solunumu tam 10 saniye değerlendirin. Solunum yoksa derhal suni solunuma/TYD'ye başlayın.",
            "**Dolaşım Kontrolü (C):** Çocuk ve yetişkinlerde şah damarından, bebeklerde kol atardamarından 3 parmak kullanarak 5 saniye süreyle nabız kontrolü yapın.",
            "**Görüşerek Bilgi Edinme:** Kendinizi tanıtıp güven sağlayın. Hastanın ismini öğrenin, olayın oluş şeklini, kronik hastalıkları, alerjileri ve kullandığı ilaçları sorun.",
            "**Baştan Aşağı Muayene:** Sırasıyla baş (kanama, morluk, kulak/burundan sıvı), boyun (ağrı/hassasiyet), göğüs kafesi (saplanmış cisim, sırt), karın boşluğu (sertlik/ağrı) ve kolları/bacakları (hissiyat/kırık) kontrol edin."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "scene_evaluation",
          title: "Olay Yerinin Değerlendirilmesi",
          description:
              "Tekrar kaza olma riskini önleme, yaralı sayısını belirleme ve olay yeri güvenliği adımları.",
          keywords: [
            "güvenlik",
            "olay yeri",
            "reflektör",
            "lpg",
            "kıvılcım",
            "yangın",
            "gaz sızıntısı",
            "emniyet"
          ],
          icon: Icons.gpp_good_rounded,
          gradientColors: [Color(0xFF009688), Color(0xFF004D40)],
          symptoms: [
            "**Tekrar Kaza Riskini Önleme:** Olay yerinde güvenli bir çevre oluşturularak yeni kazaların veya patlamaların önüne geçilir.",
            "**Durum ve Yaralı Tespiti:** Olay yerindeki toplam hasta/yaralı sayısının ve yaralanma türlerinin hızla belirlenmesidir."
          ],
          warnings: [
            "⚠️ **Kıvılcım Riski:** Gaz sızıntısı durumlarında kıvılcım oluşturabilecek ışıklandırma veya cihazların (telefon vb.) kullanılmasına izin verilmez.",
            "⚠️ **Hasta Kıpırdatılmaz:** Yangın veya patlama riski gibi acil durumlar dışında hasta/yaralı kesinlikle yerinden oynatılmamalıdır.",
            "⚠️ **Kalabalık Kontrolü:** İlkyardımı zorlaştıracak veya engelleyecek meraklı kişiler olay yerinden hızla uzaklaştırılmalıdır."
          ],
          steps: [
            "**Aracı Emniyete Alın:** Kazaya uğrayan aracın kontağını kapatın, el frenini çekin. Araç LPG'li ise bagajdaki tüp vanasını kapatın.",
            "**Olay Yerini İşaretleyin:** Yeni kazaları önlemek amacıyla kaza noktasının önüne ve arkasına görünebilir şekilde üçgen reflektörler yerleştirin.",
            "**Yangın Riskini Önleyin:** Olası patlama ve yangın risklerini önlemek için olay yerinde sigara içilmesine kesinlikle izin vermeyin.",
            "**Gaz Sızıntısı Önlemi:** Ortamda gaz varlığı söz konusu ise zehirlenmeleri önlemek için alanı havalandırın, kıvılcım üretecek ışık kullanmayın.",
            "**Hayati Bulgular ve Isı:** Yaralıyı yerinden oynatmadan hızlıca ABC yönünden değerlendirin ve üzerini örterek sıcak tutun.",
            "**Kayıt ve 112:** Hasta ve olay hakkındaki bilgileri kaydedin, 112'yi arayıp bilgi verin ve yardım ekibi gelene kadar olay yerinde kalın."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Temel Yaşam Desteği",
    description:
        "Suni solunum, kalp masajı ve soluk yolu tıkanıklığında (Heimlich) acil müdahale adımları.",
    icon: Icons.favorite_rounded,
    gradientColors: [Color(0xFFEF5350), Color(0xFFC62828)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "adult_cpr",
          title: "Yetişkinlerde (8 Yaş Üstü) Temel Yaşam Desteği",
          description:
              "Bilinci kapalı ve solunumu durmuş yetişkinlerde suni solunum, kalp masajı ve OED/AED cihazı kullanımı.",
          keywords: [
            "yetişkin",
            "cpr",
            "kalp masajı",
            "suni solunum",
            "oed",
            "aed",
            "defibrilatör",
            "temel yaşam desteği"
          ],
          icon: Icons.person_rounded,
          gradientColors: [Color(0xFFEF5350), Color(0xFFE53935)],
          stepImageUrls: [
            "lib/assets/images/yetiskin_1.png",
            "lib/assets/images/yetiskin_2.png",
            "lib/assets/images/yetiskin_3.png",
            "lib/assets/images/yetiskin_4.png",
            "lib/assets/images/yetiskin_5.png",
          ],
          symptoms: [
            "**Kalp Durması Belirtileri:** Kişide solunumun olmaması, bilincin kapalı olması, hiçbir hareket sergilememesi ve uyaranlara cevap vermemesi.",
            "**Uygulama Amacı:** Durmuş kalp ve akciğer fonksiyonlarını dışarıdan taklit ederek beyin ve hayati organların oksijenlenmesini sürdürmektir."
          ],
          warnings: [
            "⚠️ **Göğüs Basısı Derinliği:** Bası sırasında göğüs kemiği tam 5 cm aşağı inecek şekilde dik olarak bastırılmalıdır.",
            "⚠️ **OED Kullanımı:** Otomatik Eksternal Defibrilatör (OED) geldiğinde pedler ıslak olmayan, kuru göğse şemaya uygun yapıştırılmalıdır.",
            "⚠️ **Analiz Sırasında:** Cihaz kalp ritmi analizi yaparken ve şok verirken kesinlikle hastaya dokunulmamalıdır."
          ],
          steps: [
            "**Bilinç Kontrolü:** Omuzlarına dokunup 'iyi misiniz?' diye sorun. Bilinç yoksa hemen 112'yi aratın ve hastayı sert zemine sırtüstü yatırın.",
            "**Ağız İçi ve Hava Yolu:** Ağız içini kontrol edin, yabancı cisim varsa çıkarın. Baş Geri-Çene Yukarı pozisyonu vererek hava yolunu açın.",
            "**Solunum Kontrolü (ABC):** Bak-Dinle-Hisset yöntemiyle solunumu 10 saniye değerlendirin. Solunum yoksa kalp masajına hazırlanın.",
            "**Kalp Masajı (30 Bası):** Göğüs kemiğinin alt yarısına iki elinizi kenetleyerek yerleştirin. Dakikada 100 hızla göğsü 5 cm çökertecek 30 bası uygulayın.",
            "**Suni Solunum (2 Nefes):** Hastanın burnunu kapatın. Ağzınızı hastanın ağzına kenetleyip göğsü şişirecek şekilde 1 saniye süren 2 nefes üfleyin (30:2)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "child_cpr",
          title: "Çocuklarda (1-8 Yaş) Temel Yaşam Desteği",
          description:
              "Bilinci kapalı ve solunumu durmuş çocuklarda önce 2 suni solunum ile başlayan temel yaşam desteği.",
          keywords: [
            "çocuk",
            "cpr",
            "kalp masajı",
            "suni solunum",
            "kurtarıcı nefes",
            "çocuk ilkyardım"
          ],
          icon: Icons.child_care_rounded,
          gradientColors: [Color(0xFFFF7043), Color(0xFFD84315)],
          stepImageUrls: [
            "lib/assets/images/cocuk_1.png",
            "lib/assets/images/cocuk_2.png",
            "lib/assets/images/cocuk_3.png",
            "lib/assets/images/cocuk_4.png",
            "lib/assets/images/cocuk_5.png",
            "lib/assets/images/cocuk_6.png",
          ],
          symptoms: [
            "**Solunum/Kalp Durması:** Çocuğun sesli veya fiziksel uyarıya cevap vermemesi ve normal nefes almaması durumudur.",
            "**Uygulama Amacı:** Çocuklarda asfiksi (oksijensiz kalma) öncelikli olduğundan hızlıca yapay solunum desteği ile yaşamsal fonksiyonları başlatmaktır."
          ],
          warnings: [
            "⚠️ **Nefesle Başlama:** Yetişkinlerden farklı olarak çocuklarda temel yaşam desteğine ÖNCE 2 kurtarıcı nefes verilerek başlanır.",
            "⚠️ **Tek El Tekniği:** Göğüs basısı çocukların yapısına göre tek elin topuğuyla (çocuk iriyse çift elle) 5 cm çökecek şekilde yapılır.",
            "⚠️ **Yalnız İlkyardımcı:** Eğer tek başınaysanız, 30:2 döngüsünü tam 5 tur (yaklaşık 2 dakika) yaptıktan sonra 112'yi kendiniz ararsınız."
          ],
          steps: [
            "**Bilinç Kontrolü:** Çocuğun omuzlarına dokunup 'iyi misiniz?' diye sorun. Bilinç yoksa 112'yi aratın, çocuğu sert zemine yatırın.",
            "**Hava Yolu ve Solunum:** Ağız içini kontrol edip temizleyin. Baş Geri-Çene Yukarı pozisyonu verip Bak-Dinle-Hisset ile 10 saniye solunumu kontrol edin.",
            "**2 Kurtarıcı Nefes (Önce):** Solunum yoksa çocuğun burnunu kapatarak göğsü yükseltecek şekilde her biri 1 saniye süren 2 ilk nefes üfleyin.",
            "**Kalp Masajı (30 Bası):** Göğüs kemiğinin alt yarısına tek elinizin topuğunu koyun. Göğüs yüksekliğinin 1/3'ü (5 cm) kadar çökecek şekilde 30 bası yapın.",
            "**Uygulamayı Sürdürün:** 30 kalp masajından sonra 2 solunum vererek 30:2 döngüsüne kesintisiz devam edin.",
            "**112 Araması (Tek Başınaysanız):** Yalnızsanız 5 tur (30:2) uygulamadan sonra kalp masajını durdurup kendiniz 112'yi arayın ve devam edin."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "infant_cpr",
          title: "Bebeklerde (0-1 Yaş) Temel Yaşam Desteği",
          description:
              "Ayak tabanından bilinç kontrolü, ağız ve burundan birlikte nefes verme ve iki parmakla kalp masajı kuralları.",
          keywords: [
            "bebek",
            "cpr",
            "kalp masajı",
            "suni solunum",
            "iki parmak",
            "bebek ilkyardım"
          ],
          icon: Icons.child_friendly_rounded,
          gradientColors: [Color(0xFFFFA726), Color(0xFFF57C00)],
          stepImageUrls: [
            "lib/assets/images/bebek_1.png",
            "lib/assets/images/bebek_2.png",
            "lib/assets/images/bebek_3.png",
            "lib/assets/images/bebek_4.png",
            "lib/assets/images/bebek_5.png",
            "lib/assets/images/bebek_6.png",
          ],
          symptoms: [
            "**Bebek Hayati Durumu:** Bebeğin uyarılara hiç tepki vermemesi, hareket etmemesi ve solunumunun durmuş olması.",
            "**Uygulama Amacı:** Bebeklerin hassas vücut yapısına uygun basınç ve hava hacmiyle dolaşım ile solunum desteği sağlamaktır."
          ],
          warnings: [
            "⚠️ **Ayak Tabanı Kontrolü:** Bebeklerde bilinç kontrolü omuzlardan değil, ayak tabanına parmakla hafifçe vurularak yapılır.",
            "⚠️ **İki Parmak Masajı:** Göğüs basısı iki meme ucunun altındaki hattın ortasına sadece orta ve yüzük parmakla 4 cm çökecek şekilde yapılır.",
            "⚠️ **Ağız-Burun Birlikte:** Suni solunumda bebeğin ağız ve burunu kendi ağzınızın içine alarak yarım (ağız dolusu) nefes üflenir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Bebeğin ayak tabanına hafifçe vurarak bilinci kontrol edin. Bilinç yoksa 112'yi aratıp bebeği sert zemine sırtüstü yatırın.",
            "**Ağız İçi ve Koklama Pozisyonu:** Ağız içini kontrol edin. Baş geri çene yukarı pozisyonu verin ancak başı fazla geriye itmeyin (koklama pozisyonu).",
            "**Solunumu Kontrol Edin:** Bak-Dinle-Hisset yöntemiyle solunumu 10 saniye dinleyin. Solunum yoksa derhal suni solunuma başlayın.",
            "**2 Kurtarıcı Nefes (Ağız ve Burun):** Ağzınızı bebeğin ağız ve burnunu örtecek şekilde yerleştirin. Yarım (ağız dolusu) havayla 2 nefes üfleyin.",
            "**Kalp Masajı (30 Bası):** İki meme ucu hattının ortasına iki parmağınızı dik yerleştirin. Göğüs 4 cm çökecek şekilde dakikada 100 hızla 30 bası yapın.",
            "**Döngüyü Sürdürün & 112:** 30 bası ve 2 nefes (30:2) şeklinde devam edin. Tek başınaysanız 5 tur uygulamadan sonra kendiniz 112'yi arayın."
          ],
        ),
      ),
      FirstAidCategoryItem(
        subGroup: FirstAidSubGroup(
          id: "heimlich_group",
          title: "Solunum Yolu Tıkanıklığı (Heimlich Manevrası)",
          description:
              "Yetişkin, çocuk, bebek ve tek başına kalındığında solunum yolu tıkanıklığına müdahale adımları.",
          icon: Icons.emergency_rounded,
          gradientColors: [Color(0xFF26A69A), Color(0xFF00695C)],
          topics: [
            FirstAidTopic(
              id: "choking_adult_child",
              title: "Yetişkin ve Çocuklarda Solunum Yolu Tıkanıklığı",
              description:
                  "Kısmi ve tam tıkanma belirtileri, sırta vuruş ve Heimlich manevrası (karına bası) adımları.",
              keywords: [
                "tıkanma",
                "boğulma",
                "heimlich",
                "öksürük",
                "tam tıkanma",
                "kısmi tıkanma",
                "kürek kemiği",
                "karın basısı"
              ],
              icon: Icons.emergency_rounded,
              gradientColors: [Color(0xFF26A69A), Color(0xFF00695C)],
              symptoms: [
                "**Kısmi Tıkanma Belirtileri:** Kişi öksürebilir, nefes alabilir ve konuşabilir.",
                "**Tam Tıkanma Belirtileri:** Kişi nefes alamaz, konuşamaz, ellerini boynuna götürür ve rengi hızla morarır."
              ],
              warnings: [
                "⚠️ **Kısmi Tıkanmada Dokunma:** Kısmi tıkanma yaşayan kişiye kesinlikle dokunulmamalı ve sırtına vurulmamalıdır; sadece öksürmeye teşvik edilmelidir.",
                "⚠️ **Cisim Çıkarma Kuralı:** Ağız içinde yabancı cisim açıkça görülmediği sürece körlemesine parmak sokulup cisim aranmamalıdır.",
                "⚠️ **Bilinç Kapanırsa:** Hasta bilincini kaybederse derhal sert zemine yatırılıp 112 aranmalı ve Temel Yaşam Desteği uygulanmalıdır."
              ],
              steps: [
                "**Kısmi Tıkanma:** Kişi öksürüyor ve konuşabiliyorsa dokunmayın. Sadece 'öksür' diyerek öksürmeye teşvik edin.",
                "**Öne Eğin:** Tam tıkanma varsa hastanın yanına veya arkasına geçin, bir elle göğsünü destekleyerek öne eğilmesini sağlayın.",
                "**5 Sırta Vuruş:** Diğer elinizin topuğu ile iki kürek kemiği arasına süpürür tarzda hızlıca 5 kez vurun.",
                "**Heimlich Pozisyonu:** Tıkanıklık açılmadıysa arkasından sarılın. Bir elinizi yumruk yapıp başparmak içte kalacak şekilde göbek ile göğüs kemiği ucu arasına yerleştirin.",
                "**5 Karın Basısı:** Diğer elinizle yumruğu kavrayıp kuvvetlice arkaya ve yukarı doğru 5 kez bastırın.",
                "**Dönüşümlü Devam Edin:** Yabancı cisim çıkana veya bilinci kapanana kadar 5 sırta vuruş ve 5 karın basısı şeklinde dönüşümlü tekrarlayın."
              ],
            ),
            FirstAidTopic(
              id: "choking_infant",
              title: "Bebeklerde Solunum Yolu Tıkanıklığı",
              description:
                  "Bebeklerde tam tıkanmada yüzüstü sırta vuruş ve sırtüstü göğüs basısı ile yabancı cisim çıkarma adımları.",
              keywords: [
                "bebek",
                "tıkanma",
                "boğulma",
                "sırta vuruş",
                "göğüs basısı",
                "yabancı cisim",
                "bebek heimlich"
              ],
              icon: Icons.child_friendly_rounded,
              gradientColors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
              symptoms: [
                "**Kısmi Tıkanma:** Bebek ağlayabiliyor ve öksürebiliyorsa müdahale etmeyin, öksürmeye teşvik edin.",
                "**Tam Tıkanma Belirtileri:** Bebek nefes alamıyor, ağlayamıyor, sesi çıkmıyor ve rengi morarmaya başlıyor."
              ],
              warnings: [
                "⚠️ **Çene Kontrolü:** Başparmak ve diğer parmaklar yardımıyla bebeğin çenesi sıkıca kavranarak boyun desteklenmelidir.",
                "⚠️ **Baş Aşağı Pozisyon:** Bebeğin başı gövdesinden her zaman aşağıda tutulmalıdır, bu yerçekiminin cismi çıkarmasına yardım eder.",
                "⚠️ **Kör Parmak Sokmayın:** Bebeğin ağzına körlemesine parmak sokarak cisim aramayın, cismi daha derine itebilirsiniz."
              ],
              steps: [
                "**Yüzüstü Pozisyon:** Bebeği kolunuzun üzerine yüzüstü yatırın. Başparmak ve diğer parmaklarla çenesini sıkıca kavrayarak boynunu destekleyin.",
                "**Başı Aşağıda Tutun:** Bebeğin başını gövdesinden aşağıda, gergin bir pozisyonda tutun.",
                "**5 Sırta Vuruş:** El bileğinizin iç kısmı ile bebeğin sırtına, iki kürek kemiğinin arasına hafifçe 5 kez vurun.",
                "**Sırtüstü Çevirin:** Diğer kolunuzun üzerine başı elinizle kavranarak sırtüstü çevirin. Yabancı cismin çıkıp çıkmadığına bakın.",
                "**5 Göğüs Basısı:** Çıkmadıysa başı gövdesinden aşağıda tutarak iki parmakla göğüs kemiğinin alt kısmına 5 kez baskı uygulayın.",
                "**Dönüşümlü Devam Edin:** Cisim çıkana kadar 5 sırta vuruş ve 5 göğüs basısı şeklinde devam edin. Bilinç kapanırsa 112'yi arayıp TYD başlayın."
              ],
            ),
            FirstAidTopic(
              id: "choking_self",
              title: "Tek Başınıza Heimlich (Kendi Kendinize Müdahale)",
              description:
                  "Yalnızken solunum yolunuz tıkandığında kendinize uygulayabileceğiniz Heimlich manevrası adımları.",
              keywords: [
                "tek başına",
                "heimlich",
                "kendi kendine",
                "boğulma",
                "yalnız",
                "sandalye",
                "yumruk"
              ],
              icon: Icons.person_rounded,
              gradientColors: [Color(0xFF7E57C2), Color(0xFF4527A0)],
              symptoms: [
                "**Tam Tıkanma Durumu:** Nefes alamıyorsunuz, konuşamıyorsunuz ve etrafta size yardım edecek kimse yok.",
                "**Uygulama Amacı:** Diyafram altında oluşturulan basınçla akciğerlerdeki kalan havayı kullanarak yabancı cismi dışarı atmaktır."
              ],
              warnings: [
                "⚠️ **Panik Yapmayın:** Panik nefes tüketimini hızlandırır. Sakin kalıp hemen müdahaleye başlayın.",
                "⚠️ **Sert Yüzey Seçimi:** Sandalye arkalığı, masa kenarı veya tezgah gibi karın bölgenize denk gelen sert bir yüzey bulun.",
                "⚠️ **Hemen 112:** Cisim çıktıktan sonra veya çıkmıyorsa bilinciniz kapanmadan 112'yi arayın."
              ],
              steps: [
                "**Yumruğunuzu Yerleştirin:** Bir elinizi yumruk yapın. Başparmak tarafını göbek deliğinizin hemen üzerine, göğüs kemiği ucunun altına yerleştirin.",
                "**Diğer Elinizle Kavrayın:** Diğer elinizle yumruğunuzu sıkıca kavrayın.",
                "**İçe ve Yukarı Bastırın:** Hızlı bir hareketle yumruğunuzu içeri ve yukarı doğru kuvvetlice bastırın.",
                "**Sert Yüzeye Yaslanın:** Cisim çıkmadıysa bir sandalye arkalığı, masa kenarı veya tezgah gibi sert bir yüzeye karın bölgenizle (göbek üstüyle) yaslanın.",
                "**Baskı Uygulayın:** Vücudunuzu sert yüzeyin kenarına doğru hızla ileri iterek karın bölgenize basınç uygulayın.",
                "**Cisim Çıkana Kadar Tekrarlayın:** Yabancı cisim çıkana kadar bu hareketleri tekrarlayın. Başarılı olduğunuzda bile 112'yi arayıp kontrol olun."
              ],
            ),
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "oed_usage",
          title: "Otomatik Eksternal Defibrilatör (Şok Cihazı) Kullanımı",
          description:
              "Ani kalp durmalarında kalbe şok uygulaması yapan OED cihazının yetişkin, çocuk ve bebeklerde kullanım kuralları.",
          keywords: [
            "oed",
            "aed",
            "defibrilatör",
            "şok",
            "elektrot",
            "ped",
            "yarı otomatik",
            "tam otomatik"
          ],
          icon: Icons.bolt_rounded,
          gradientColors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          stepImageUrls: [
            "lib/assets/images/oed_1.png",
            "lib/assets/images/oed_2.png",
            "lib/assets/images/oed_3.png",
            "lib/assets/images/oed_4.png",
            "lib/assets/images/oed_5.jpg",
            "lib/assets/images/oed_6.png",
          ],
          symptoms: [
            "**OED Nedir:** Kalpteki ölümcül ritimsizlikleri (VF/VT) algılayıp şok vererek kalbi normal ritmine döndüren cihazdır.",
            "**Kullanım Koşulu:** Cihaz, ani kalp durması yaşayıp solunumu olmayan tüm hastalarda kullanılır."
          ],
          warnings: [
            "⚠️ **Dokunmayın:** Cihaz kalp ritmi analizi yaparken ve şok verirken kesinlikle hastaya dokunulmamalıdır.",
            "⚠️ **Islaklık ve Kıl:** Pedlerin yapışacağı yer ıslaksa kurulanmalı, kıllıysa tıraş edilmelidir. Kalp pili varsa ped 2.5 cm uzağına yapıştırılmalıdır.",
            "⚠️ **Ped Teması:** Pedlerin çocuk/bebek göğsünde birbirine kesinlikle değmediğinden emin olunmalıdır."
          ],
          steps: [
            "**Cihazı Çalıştırın:** OED'yi hastanın yanına yerleştirin ve açma düğmesine basarak çalıştırın (Otomatik açılan modellerde kapağı açın).",
            "**Yetişkin Ped Yerleşimi:** Pedleri çıplak göğse yapıştırın: Biri sağ köprücük kemiğinin altına, diğeri sol meme altına.",
            "**Çocuk/Bebek Ped Yerleşimi:** 8 yaşından küçüklerde pedler birbirine değiyorsa: Biri göğüs ön ortasına, diğeri iki kürek kemiği arasına (arkaya) yapıştırılır.",
            "**Kalp Ritm Analizi:** Cihaz ritim analizi yaparken hastaya dokunmayın, çevredekileri yüksek sesle uyarın.",
            "**Şoku Uygulayın:** Şok önerilirse, kimsenin hastaya dokunmadığından emin olup yarı otomatikte şok butonuna basın (tam otomatikte cihaz kendi verir).",
            "**Temel Yaşam Desteğine Devam Edin:** Şok sonrasında cihazın sesli komutlarını takip ederek derhal 30:2 şeklinde kalp masajı ve suni solunuma devam edin."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Kanamalar ve Yara Bakımı",
    description:
        "Dış kanama, ağır kanama, iç kanama ve özel bölge kanamalarında doğru ilkyardım müdahalesi.",
    icon: Icons.bloodtype_rounded,
    gradientColors: [Color(0xFFE53935), Color(0xFF880E4F)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "external_bleeding",
          title: "Dış Kanama ve Yara Bakımı",
          description:
              "Kılcal, venöz ve arteriyel kanama türleri ile yara temizleme, baskı uygulama ve pansuman adımları.",
          keywords: [
            "dış kanama",
            "yara",
            "pansuman",
            "baskı",
            "kılcal",
            "venöz",
            "arteriyel",
            "temizleme"
          ],
          icon: Icons.healing_rounded,
          gradientColors: [Color(0xFFE53935), Color(0xFFC62828)],
          symptoms: [
            "**Kılcal Kanama:** Yüzeysel sıyrık veya çiziklerden sızar tarzda akar. Genellikle kendiliğinden durur.",
            "**Venöz (Toplardamar) Kanama:** Koyu kırmızı renkte, devamlı ve sabit bir akışla gelir. Baskı ile kontrol altına alınabilir.",
            "**Arteriyel (Atardamar) Kanama:** Açık kırmızı renkte, kalp atışıyla senkronize fışkırır tarzda gelir. En tehlikeli kanama türüdür."
          ],
          warnings: [
            "⚠️ **Yabancı Cisim:** Yaraya saplanmış cisim KESİNLİKLE çıkarılmamalı, etrafı desteklenerek sabitlenmelidir.",
            "⚠️ **Yara Temizliği:** Yara yeri ağızla emilmemeli, temizlenmemiş bezle kapatılmamalıdır.",
            "⚠️ **Turnike Son Çare:** Turnike yalnızca diğer yöntemler işe yaramadığında ve uzuv kaybı riski varsa uygulanır."
          ],
          steps: [
            "**Güvenlik ve Eldiven:** Mümkünse tek kullanımlık eldiven giyin. Kan temasından kaçının.",
            "**Baskı Uygulayın:** Temiz bir bez veya gazlı bez ile yaranın üzerine doğrudan sert baskı uygulayın ve bırakmayın.",
            "**Yara Temizliği:** Kanama hafif ise yaraya bol temiz (tercihen steril) su akıtarak yabancı maddeleri temizleyin.",
            "**Pansuman:** Temizlenen yarayı steril gazlı bezle kapatın, bantla sabitleyin. Kanama geçiyorsa bezi değiştirmeyin, üstüne ekleyin.",
            "**Uzvu Yükseltin:** Mümkünse kanayan uzvu kalp seviyesinin üzerine kaldırın; bu kan akışını yavaşlatır.",
            "**112'yi Arayın:** Kanama 10 dakika baskıya rağmen durmuyor veya derin/büyük yara varsa hemen 112'yi arayın."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "severe_bleeding",
          title: "Ağır ve Hayati Kanamalar",
          description:
              "Arteriyel kanama, ampütasyon ve saplanmış cisim gibi hayatı tehdit eden kanamalarda turnike ve baskı noktası uygulaması.",
          keywords: [
            "ağır kanama",
            "arteriyel",
            "turnike",
            "bası noktası",
            "ampütasyon",
            "saplanmış cisim",
            "hayati kanama"
          ],
          icon: Icons.emergency_rounded,
          gradientColors: [Color(0xFFB71C1C), Color(0xFF880E4F)],
          symptoms: [
            "**Hayati Kanama Belirtileri:** Kırmızı kanın fışkırması, hızla genişleyen kan gölü, soluk/soğuk/terli cilt ve bilinç değişikliği.",
            "**Ampütasyon:** Uzuv veya parmak kısmen ya da tamamen kopmuştur. Kopan parça steril bezle sarılıp soğutularak korunur.",
            "**Saplanmış Cisim:** Bıçak, cam veya metal gibi bir cisim dokuya saplanmış durumdadır. Asla çıkarılmamalıdır."
          ],
          warnings: [
            "⚠️ **Turnike Zamanı:** Turnike uygulandığı saat not edilmeli ve 112 ekiplerine mutlaka bildirilmelidir.",
            "⚠️ **Turnike Gevşetme:** İlkyardımcı turnikeyi gevşetmemelidir; bu karar tıbbi personele aittir.",
            "⚠️ **Saplanmış Cisim:** Cisme dokunmayın. Hareket etmemesi için her iki yanına bez veya sargı koyarak sabitleyin."
          ],
          steps: [
            "**Doğrudan Baskı:** Yaranın üzerine kat kat gazlı bez koyup avucunuzla güçlü ve kesintisiz baskı uygulayın (en az 10 dakika).",
            "**Baskı Noktası:** Doğrudan baskı yetmiyorsa kanayan bölgeye giden damarı kemik üzerinde parmakla sıkıştırın (koltuk altı, kasık, kol içi).",
            "**Turnike Uygulayın:** Baskı noktası da yetersizse uzuv kanamasında yaranın 5-8 cm üstüne (kalbe yakın) kemer, kravat veya özel turnike bağlayın.",
            "**Turnikeyi Sabitleyin:** Kanama duruncaya kadar sıkın. Saati not edin. Turnikenin üstüne 'T: saat' yazın.",
            "**Ampütasyonda Kopan Parça:** Kopan uzvu ıslak steril bez veya plastik torba ile sarıp buzlu suya (buz ile doğrudan temas ettirmeden) koyun.",
            "**112 ve Şok Önlemi:** Hemen 112'yi arayın. Hastayı yatırıp bacaklarını yükseltin, üzerini örtün ve bilincini açık tutmaya çalışın."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "internal_bleeding",
          title: "İç Kanama",
          description:
              "Dışarıdan görülemeyen iç kanamanın belirtileri, şok riski ve ilkyardımcının yapabileceği müdahaleler.",
          keywords: [
            "iç kanama",
            "şok",
            "karın ağrısı",
            "morluk",
            "hipovolemik",
            "düşme",
            "trafik kazası"
          ],
          icon: Icons.monitor_heart_rounded,
          gradientColors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
          symptoms: [
            "**Genel Belirtiler:** Kaza/düşme/darbeden sonra cildin soluklaşması, soğuk ve yapışkan ter, hızlı-zayıf nabız ve bilinç bulanıklığı.",
            "**Karın İçi Kanama:** Karında şişlik, sertlik veya hassasiyet; bazen göbek çevresinde veya yan bölgede morluk oluşur.",
            "**Göğüs İçi Kanama:** Nefes darlığı, göğüs ağrısı, öksürükle kan gelmesi ve dudaklarda morarma görülür."
          ],
          warnings: [
            "⚠️ **Ağızdan Yiyecek/İçecek:** İç kanamadan şüphelenilen hastaya KESİNLİKLE ağızdan hiçbir şey verilmemelidir.",
            "⚠️ **Hareket Ettirmeyin:** Aksi ispat edilene kadar omurga yaralanması şüphesiyle hareket ettirmekten kaçının.",
            "⚠️ **Isıtmayın:** Hasta üşüdüğünü söylese de sıcak su torbası veya elektrikli battaniye kullanmayın; kan akışını hızlandırır."
          ],
          steps: [
            "**İç Kanama Şüphesi:** Kaza, düşme veya darbe sonrasında yukarıdaki belirtilerden biri varsa iç kanama ihtimalini düşünün.",
            "**112'yi Arayın:** Vakit kaybetmeden 112'yi arayın. İç kanama kesinlikle hastane gerektiren bir durumdur.",
            "**Hastayı Yatırın:** Hastayı sırtüstü yatırın. Bacaklarını yaklaşık 30 cm yükselterek şoku geciktirin (karın veya göğüs travması şüphesi yoksa).",
            "**Sıcak Tutun:** Hastanın üzerini bir battaniye veya kıyafetle örtün; ısı kaybını önleyin.",
            "**Bilinci Açık Tutun:** Hasta ile konuşun, sorular sorun. Bilinci kapanırsa kurtarma pozisyonuna alın.",
            "**Nabız ve Solunumu Takip Edin:** Yardım gelene kadar nabız ve solunumu düzenli kontrol edin; durması halinde TYD'ye başlayın."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "special_area_bleeding",
          title: "Özel Bölge Kanamaları",
          description:
              "Burun, kulak, göz ve diş çekimi sonrası kanamalarda doğru ilkyardım yöntemleri.",
          keywords: [
            "burun kanaması",
            "kulak kanaması",
            "göz yaralanması",
            "diş kanaması",
            "epistaksis",
            "kafa travması"
          ],
          icon: Icons.face_rounded,
          gradientColors: [Color(0xFFAD1457), Color(0xFF880E4F)],
          symptoms: [
            "**Burun Kanaması:** Burundan kırmızı kan akması; kafa travmasından sonra geliyorsa BOS (beyin omurilik sıvısı) ihtimali ciddidir.",
            "**Kulak Kanaması:** Dışarıdan darbeyle beraber kulaktan kan veya sıvı gelmesi kafatası kırığı belirtisi olabilir.",
            "**Göz Yaralanması:** Göze yabancı cisim batması, kimyasal madde sıçraması veya künt darbe sonrası ağrı ve görmede bozulma."
          ],
          warnings: [
            "⚠️ **Kafa Travmasında Burun/Kulak Kanaması:** Başa darbe sonrası burun veya kulaktan akan sıvı durdurulmaya çalışılmamalı, hemen 112 aranmalıdır.",
            "⚠️ **Kulağa Parmak Sokmayın:** Kulak kanamasında kulağa pamuk, parmak veya herhangi bir cisim sokulmamalıdır.",
            "⚠️ **Göze Dokunmayın:** Göze batan cisim çıkarılmaya çalışılmamalı; göz kapatılıp örtülerek nakil sağlanmalıdır."
          ],
          steps: [
            "**Burun Kanaması - Öne Eğin:** Hastayı öne eğin (geriye değil). Başı öne eğik tutmak kanın yutulmasını ve boğulma riskini önler.",
            "**Burun Kanaması - Sıkın:** Başparmak ve işaret parmağıyla burun kanatlarını (yumuşak kısmını) 10-15 dakika kesintisiz sıkın. Bırakmayın.",
            "**Kulak Kanaması:** Hastayı kanayan kulağı alta gelecek şekilde yan yatırın. Kanı durdurmaya çalışmayın; steril bir bez koyup 112'yi arayın.",
            "**Göze Yabancı Cisim:** Gözü ovalamayın. Bol temiz suyla gözü dıştan içe doğru yıkayın. Cisim çıkmıyorsa gözü kapatıp hastaneye gidin.",
            "**Göze Kimyasal Madde:** En az 15-20 dakika bol akan suyla yıkayın. Kontakt lens varsa çıkarın. Ardından hemen hastaneye gidin.",
            "**Diş Çekimi Kanaması:** Rulo yapılmış steril gazlı bezi çekim yerine koyup 20-30 dakika ısırın. Aspirin kullanmayın, kanama artar."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Yaralanmalarda İlkyardım",
    description:
        "Genel yaralanmalar, ciddi yaralar, delici göğüs ve karın yaralanmaları ile kafatası ve omurga yaralanmalarında ilkyardım.",
    icon: Icons.personal_injury_rounded,
    gradientColors: [Color(0xFF6D4C41), Color(0xFF3E2723)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "general_wounds",
          title: "Genel Yaralanmalar ve Yara Türleri",
          description:
              "Yara türleri (kesik, ezikli, delici, parçalı, kirli), ortak belirtiler ve genel yaralanmalarda ilkyardım adımları.",
          keywords: [
            "yara",
            "kesik",
            "ezik",
            "delici",
            "parçalı",
            "kirli yara",
            "tetanos",
            "enfeksiyon",
            "yabancı cisim"
          ],
          icon: Icons.healing_rounded,
          gradientColors: [Color(0xFF6D4C41), Color(0xFF4E342E)],
          symptoms: [
            "**Kesik Yaralar:** Bıçak, çakı, cam gibi kesici aletlerle oluşur. Genellikle basit yaralardır; derinlikleri kolay belirlenir.",
            "**Ezikli Yaralar:** Taş, yumruk ya da sopa gibi etkenlerin şiddetli çarpmasıyla oluşur. Yara kenarları eziktir; çok fazla kanama olmaz ancak doku zedelenmesi ve hassasiyet vardır.",
            "**Delici Yaralar:** Uzun ve sivri aletlerle oluşur. Yüzey üzerinde derinlik hakimdir; aldatıcı olabilir ve tetanos tehlikesi vardır.",
            "**Parçalı Yaralar:** Dokular üzerinde bir çekme etkisiyle meydana gelir; deri ve ilgili tüm organ zarar görebilir.",
            "**Kirli (Enfekte) Yaralar:** Mikrop kapma ihtimali olan yaralardır. 6 saatten fazla gecikmiş, dikişleri ayrılmış, çok kirli/derin, ateşli silah, ısırık veya sokmayla oluşan yaralar enfeksiyon riski yüksektir."
          ],
          warnings: [
            "⚠️ **Yabancı Cisim:** Yaradaki yabancı cisimlere dokunulmamalıdır.",
            "⚠️ **Tetanos:** Tüm yaralanmalarda hasta/yaralı tetanos konusunda uyarılmalıdır.",
            "⚠️ **Yara İçi:** Yara içi kesinlikle kurcalanmamalıdır."
          ],
          steps: [
            "**Yaşam Bulgularını Değerlendirin:** ABC yöntemiyle (Havayolu, Solunum, Dolaşım) hasta/yaralının durumunu kontrol edin.",
            "**Yara Yerini Değerlendirin:** Yaranın oluş şekli, süresi, yabancı cisim varlığı ve kanama durumunu belirleyin.",
            "**Kanamayı Durdurun:** Yara yerine temiz bir bezle baskı uygulayarak kanamayı durdurun.",
            "**Yarayı Örtün:** Yara üzerini temiz bir bez ile kapatın.",
            "**Sağlık Kuruluşuna Gönderin:** Hasta/yaralının sağlık kuruluşuna gitmesini sağlayın.",
            "**Tetanos Uyarısı:** Tetanos aşısı konusunda hasta/yaralıyı bilgilendirin."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "serious_wounds",
          title: "Ciddi Yaralanmalarda İlkyardım",
          description:
              "Kenarları birleşmeyen, kanaması durdurulamayan, yabancı cisim saplanmış ve kas/kemik görülen ciddi yaralanmalarda ilkyardım.",
          keywords: [
            "ciddi yara",
            "derin yara",
            "yabancı cisim",
            "kas",
            "kemik",
            "ısırık",
            "hayvan ısırığı",
            "pansuman"
          ],
          icon: Icons.emergency_rounded,
          gradientColors: [Color(0xFF4E342E), Color(0xFF3E2723)],
          symptoms: [
            "**Ciddi Yaralanma Kriterleri:** Kenarları birleşmeyen veya 2-3 cm'den büyük yaralar, kanaması durdurulamayan yaralar, kas veya kemiğin göründüğü yaralar.",
            "**Diğer Ciddi Durumlar:** Delici aletlerle oluşan yaralar, yabancı cisim saplanmış yaralar, insan veya hayvan ısırıkları, görünürde iz bırakma ihtimali olan yaralar."
          ],
          warnings: [
            "⚠️ **Saplanmış Cisim:** Yaraya saplanan yabancı cisimler kesinlikle çıkarılmaz.",
            "⚠️ **Yara İçi:** Yara içi kurcalanmamalıdır.",
            "⚠️ **Tıbbi Yardım:** Ciddi yaralanmalarda mutlaka tıbbi yardım istenir (112)."
          ],
          steps: [
            "**Yabancı Cismi Çıkarmayın:** Yaraya saplanan yabancı cisimler çıkarılmaz; sabit tutulur.",
            "**Kanamayı Durdurun:** Yarada kanama varsa temiz bezle baskı uygulayarak durdurun.",
            "**Yara İçini Kurcalamayın:** Yara içine parmak sokmayın, içini araştırmayın.",
            "**Nemli Bezle Örtün:** Yarayı nemli temiz bir bezle örtün.",
            "**Bandaj Uygulayın:** Yara üzerine bandaj uygulayın; bezi sıkmadan sabitleyin.",
            "**112'yi Arayın:** Tıbbi yardım isteyin ve yardım gelene kadar hasta/yaralının yanında kalın."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "chest_wounds",
          title: "Delici Göğüs Yaralanmaları",
          description:
              "Göğse giren cismin akciğer zarını yaralaması sonucu oluşan açık pnömotoraks belirtileri ve hava geçirmez kapatma yöntemi.",
          keywords: [
            "delici göğüs",
            "pnömotoraks",
            "akciğer",
            "göğüs yarası",
            "nefes darlığı",
            "kan tükürme",
            "morarma",
            "hava geçirmez"
          ],
          icon: Icons.air_rounded,
          gradientColors: [Color(0xFF37474F), Color(0xFF263238)],
          symptoms: [
            "**Delici Göğüs Belirtileri:** Göğsün içine giren cisim akciğer zarı ve akciğeri yaralar.",
            "**Görülen Belirtiler:** Yoğun ağrı, solunum zorluğu, morarma, kan tükürme ve açık pnömotoraks (göğüsteki yarada nefes alıyor görüntüsü)."
          ],
          warnings: [
            "⚠️ **Şok Riski:** Açık pnömotoraksta şok ihtimali çok yüksektir; şok önlemleri mutlaka alınmalıdır.",
            "⚠️ **Ağızdan Bir Şey Vermeyin:** Hasta/yaralıya ağızdan hiçbir şey verilmez.",
            "⚠️ **Hava Çıkışı:** Yara üzerine konan bezin bir ucu açık bırakılır; nefes alma sırasında hava girmesi engellenir, nefes verirken çıkabilir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Hasta/yaralının bilinç kontrolü yapılır.",
            "**Yaşam Bulgularını Değerlendirin:** ABC yöntemiyle yaşam bulguları değerlendirilir.",
            "**Yarayı Kapatın:** Yara üzerine plastik poşet, naylon vb. sarılmış bir bezle kapatılır.",
            "**Bir Ucu Açık Bırakın:** Nefes alma sırasında yaraya hava girmesini engellemek, nefes verirken havanın dışarı çıkmasını sağlamak için bezin bir ucu açık bırakılır.",
            "**Pozisyon Verin:** Hasta/yaralı bilinci açıksa yarı oturur pozisyonda oturtulur.",
            "**112'yi Arayın ve Takip Edin:** Tıbbi yardım istenir. Yaşam bulguları sık sık kontrol edilir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "abdominal_wounds",
          title: "Delici Karın Yaralanmaları",
          description:
              "Karın bölgesindeki organların zarar görmesi, iç/dış kanama, dışarı çıkan organlar ve şok riskine karşı ilkyardım.",
          keywords: [
            "delici karın",
            "karın yaralanması",
            "iç organ",
            "bağırsak",
            "karın şişlik",
            "şok",
            "karın sertliği"
          ],
          icon: Icons.personal_injury_rounded,
          gradientColors: [Color(0xFF558B2F), Color(0xFF33691E)],
          symptoms: [
            "**Olası Sorunlar:** Karın bölgesindeki organlar zarar görebilir; iç ve dış kanama ile buna bağlı şok oluşabilir.",
            "**Ciddiyet Belirtisi:** Karın tahta gibi sert ve çok ağrılıysa durum ciddidir. Bağırsaklar dışarı çıkabilir."
          ],
          warnings: [
            "⚠️ **Dışarı Çıkan Organ:** Dışarı çıkan organlar içeri sokulmaya çalışılmaz; üzerine geniş ve nemli temiz bir bez örtülür.",
            "⚠️ **Ağızdan Bir Şey Vermeyin:** Hasta/yaralıya ağızdan yiyecek ya da içecek hiçbir şey verilmez.",
            "⚠️ **Isı Kaybı:** Üzeri örtülerek ısı kaybı önlenir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Hasta/yaralının bilinç kontrolü yapılır.",
            "**Yaşam Bulgularını Kontrol Edin:** Yaşam bulguları kontrol edilir.",
            "**Organı Örtün:** Dışarı çıkan organlar içeri sokulmaz; üzerine geniş ve nemli temiz bir bez örtülür.",
            "**Pozisyon Verin:** Bilinci yerindeyse sırt üstü pozisyonda, bacakları bükülmüş olarak yatırılır ve üzeri örtülür.",
            "**Yaşam Bulgularını İzleyin:** Yaşam bulguları sık sık izlenir.",
            "**112'yi Arayın:** Tıbbi yardım istenir; yardım gelene kadar yanında kalınır."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "skull_spine_injuries",
          title: "Kafatası ve Omurga Yaralanmaları",
          description:
              "Trafik kazalarında ölümlerin %80'ini oluşturan kafatası ve omurga yaralanmalarında baş-boyun-gövde eksenini koruyarak ilkyardım.",
          keywords: [
            "kafatası",
            "omurga",
            "boyun",
            "bel kemiği",
            "bilinç kaybı",
            "trafik kazası",
            "düşme",
            "his kaybı",
            "kırık"
          ],
          icon: Icons.accessible_rounded,
          gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          symptoms: [
            "**Belirtiler:** Bilinç düzeyinde değişmeler, hafıza kaybı; başta, boyunda ve sırtta ağrı; elde ve parmaklarda karıncalanma ya da his kaybı.",
            "**Diğer Belirtiler:** Vücudun herhangi bir yerinde tam ya da kısmi hareket kaybı, baş ya da bel kemiğinde şekil bozukluğu, burun ve kulaktan beyin omurilik sıvısı ve kan gelmesi, kulak ve göz çevresinde morluk, sarsıntı, denge kaybı.",
            "**Kafa ve Omurga Sayılması Gereken Durumlar:** Hiçbir belirti olmasa bile; yüz ve köprücük kemiği yaralanmaları, tüm düşme vakaları, trafik kazaları ve bilinci kapalı tüm hasta/yaralılar kafa ve omurga yaralanması olarak varsayılmalıdır."
          ],
          warnings: [
            "⚠️ **Hareket Ettirmeyin:** Bilinci açıksa hareket etmemesi sağlanır. Herhangi bir tehlike yoksa kesinlikle yerinden oynatılmaz.",
            "⚠️ **Baş-Boyun-Gövde Ekseni:** Baş-boyun-gövde ekseni hiçbir şekilde bozulmamalıdır.",
            "⚠️ **Sarsıntı:** Taşınma ve sevk sırasında hasta/yaralının sarsıntıya maruz kalmaması gerekir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Bilinç kontrolü yapılır.",
            "**Yaşam Bulgularını Değerlendirin:** Yaşam bulguları değerlendirilir (ABC).",
            "**Hemen 112'yi Arayın:** Tıbbi yardım hemen istenir (112).",
            "**Hareket Ettirmeyin:** Bilinci açıksa hareket etmemesi sağlanır. Tehlike varsa düz pozisyonda sürüklenir.",
            "**Ekseni Koruyun:** Baş-boyun-gövde ekseni bozulmadan sedyeye alınması için gelen ekibe bilgi verilir.",
            "**Yanında Kalın ve Kaydedin:** Tüm yapılanlar ve hasta/yaralı hakkındaki bilgiler kaydedilmeli ve gelen ekibe bildirilmelidir. Asla yalnız bırakılmamalıdır."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Yanık, Sıcak Çarpması ve Donma",
    description:
        "Isı, kimyasal ve elektrik yanıkları ile sıcak çarpması ve donma durumlarında ilkyardım uygulamaları.",
    icon: Icons.local_fire_department_rounded,
    gradientColors: [Color(0xFFE65100), Color(0xFFBF360C)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "heat_burns",
          title: "Isı ile Oluşan Yanıklar",
          description:
              "Yanık dereceleri (1-2-3), yanığın ciddiyetini belirleyen faktörler ve ısı yanıklarında ilkyardım adımları.",
          keywords: [
            "yanık",
            "ısı yanığı",
            "1. derece",
            "2. derece",
            "3. derece",
            "kabarcık",
            "kızarıklık",
            "şok",
            "sıcak su"
          ],
          icon: Icons.local_fire_department_rounded,
          gradientColors: [Color(0xFFE65100), Color(0xFFBF360C)],
          symptoms: [
            "**1. Derece Yanık:** Deride kızarıklık, ağrı ve yanık bölgede ödem vardır. Yaklaşık 48 saatte iyileşir.",
            "**2. Derece Yanık:** Deride içi su dolu kabarcıklar (bül) vardır ve ağrılıdır. Derinin kendini yenilemesiyle iyileşir.",
            "**3. Derece Yanık:** Derinin tüm tabakaları etkilenmiştir; kaslar, sinirler ve damarlar zarar görür. Beyazdan siyaha kadar renk değişimi görülür. Sinirler zarar gördüğünden ağrı yoktur.",
            "**Yanığın Olumsuz Etkileri:** Derinlik, yaygınlık ve bölgeye bağlı organ/sistem bozukluğuna yol açar. Ağrı ve sıvı kaybına bağlı şok ve enfeksiyon oluşabilir."
          ],
          warnings: [
            "⚠️ **Su Toplamış Bölgeler:** Su toplamış kabarcıklar (bül) kesinlikle patlatılmaz.",
            "⚠️ **İlaç veya Merhem:** Yanık üzerine ilaç ya da yanık merhemi gibi maddeler sürülmemelidir.",
            "⚠️ **Yanık Bölgeler:** Yanık bölgeler birbirine bandaj yapılmamalıdır."
          ],
          steps: [
            "**Paniği Önleyin:** Kişi hâlâ yanıyorsa koşmasını engelleyin; battaniye ya da örtüyle kapatıp yuvarlanmasını sağlayın.",
            "**Yaşam Bulgularını Değerlendirin:** ABC yöntemiyle değerlendirin; solunum yolunun etkilenip etkilenmediğini kontrol edin.",
            "**Giysileri Çıkarın:** Yanmış alandaki deriler kaldırılmadan giysiler çıkarılır. Ödem oluşacağı düşünülerek yüzük, bilezik, saat gibi eşyalar çıkarılır.",
            "**20 Dakika Su:** Yanık bölge en az 20 dakika çeşme suyu altında tutulur. (Yanık yüzeyi büyükse ısı kaybı çok olacağından su uygulanmaz.)",
            "**Temiz Bezle Örtün:** Yanık üzeri temiz bir bezle örtülür; hasta battaniye ile sarılır.",
            "**112'yi Arayın:** Yanık geniş ise bilinçli ve bulantısı yoksa ağızdan sıvı (1 lt su + 1 çay kaşığı karbonat + 1 çay kaşığı tuz) verilir; tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "chemical_burns",
          title: "Kimyasal Yanıklar",
          description:
              "Asit/alkali gibi kimyasal maddelerin deriyle temasında en kısa sürede kimyasalı uzaklaştırma ve bol suyla yıkama adımları.",
          keywords: [
            "kimyasal yanık",
            "asit",
            "alkali",
            "kimyasal madde",
            "deri",
            "yıkama"
          ],
          icon: Icons.science_rounded,
          gradientColors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
          symptoms: [
            "**Kimyasal Yanık:** Asit veya alkali gibi kimyasal maddelerin deriyle temasıyla oluşan yanıklardır.",
            "**Risk:** Kimyasal madde deriyle temas ettiği sürece zarar vermeye devam eder; en kısa sürede temas kesilmelidir."
          ],
          warnings: [
            "⚠️ **Tazyiksiz Su:** Yıkama sırasında tazyikli su kullanılmaz; kimyasalın yayılmasına neden olabilir.",
            "⚠️ **Giysiler:** Kimyasalın bulaştığı giysiler mutlaka çıkarılır.",
            "⚠️ **Tıbbi Yardım:** Kimyasal yanıklarda mutlaka tıbbi yardım istenir (112)."
          ],
          steps: [
            "**Teması Kesin:** Deriyle temas eden kimyasal maddenin en kısa sürede deriyle teması kesilmelidir.",
            "**Bol Suyla Yıkayın:** Bölge bol tazyiksiz suyla en az 15-20 dakika yumuşak bir şekilde yıkanmalıdır.",
            "**Giysileri Çıkarın:** Kimyasalın bulaştığı giysiler çıkarılmalıdır.",
            "**Örtün:** Hasta/yaralı örtülmelidir.",
            "**112'yi Arayın:** Tıbbi yardım istenmelidir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "electric_burns",
          title: "Elektrik Yanıkları",
          description:
              "Elektrik akımına maruz kalan kişide önce akımı kesme, ardından ABC değerlendirmesi ve tıbbi yardım adımları.",
          keywords: [
            "elektrik yanığı",
            "elektrik çarpması",
            "akım",
            "elektrik kesme",
            "tahta çubuk",
            "su yasak"
          ],
          icon: Icons.bolt_rounded,
          gradientColors: [Color(0xFFF9A825), Color(0xFFF57F17)],
          symptoms: [
            "**Elektrik Yanığı:** Elektrik akımının vücuttan geçmesiyle oluşur. Dışarıdan küçük görünse de içeride ciddi doku hasarı olabilir.",
            "**Tehlike:** Elektrik akımı kesilmeden kişiye dokunmak, müdahale edeni de tehlikeye atar."
          ],
          warnings: [
            "⚠️ **Önce Akımı Kesin:** Hasta/yaralıya dokunmadan önce elektrik akımı kesilmelidir; kesme imkânı yoksa tahta çubuk ya da ip gibi yalıtkan bir cisimle elektrik teması kesilmelidir.",
            "⚠️ **Su ile Müdahale Yasak:** Hasta/yaralıya kesinlikle su ile müdahale edilmemelidir.",
            "⚠️ **Hareket Ettirmeyin:** Hasta/yaralı hareket ettirilmemelidir."
          ],
          steps: [
            "**Soğukkanlı Olun:** Panik yapmayın; kendinin ve çevrenin güvenliğini sağlayın.",
            "**Elektriği Kesin:** Akımı kesin; imkân yoksa tahta çubuk veya ip gibi yalıtkan bir cisimle hastanın elektrikle temasını kesin.",
            "**ABC Değerlendirmesi:** Hasta/yaralının yaşam bulguları (Havayolu, Solunum, Dolaşım) değerlendirilmelidir.",
            "**Su Kullanmayın:** Hasta/yaralıya kesinlikle su ile müdahale edilmez.",
            "**Hareket Ettirmeyin:** Omurga yaralanması ihtimaliyle hasta/yaralı hareket ettirilmez.",
            "**Yarayı Örtün ve 112'yi Arayın:** Hasar gören bölgenin üzeri temiz bir bezle örtülür; tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "heat_stroke",
          title: "Sıcak Çarpması",
          description:
              "Yüksek ısı ve nem sonucu vücut ısısının ayarlanamamasıyla ortaya çıkan sıcak çarpmasının belirtileri, risk grupları ve ilkyardım.",
          keywords: [
            "sıcak çarpması",
            "güneş çarpması",
            "kramlar",
            "baş dönmesi",
            "bilinç kaybı",
            "terleme",
            "sıvı"
          ],
          icon: Icons.wb_sunny_rounded,
          gradientColors: [Color(0xFFFF6F00), Color(0xFFE65100)],
          symptoms: [
            "**Belirtiler:** Adale krampları, güçsüzlük, yorgunluk, baş dönmesi, davranış bozukluğu, sinirlilik, solgun ve sıcak deri, bol terleme (daha sonra azalır), mide krampları, kusma, bulantı, bilinç kaybı, hayal görme ve hızlı nabız.",
            "**Risk Grupları:** Kalp, tansiyon, diyabet, kanser, böbrek hastaları; 65 yaş üzeri ve 5 yaş altındakiler; hamileler, aşırı kilolu veya zayıflar; yeterli su içmeyenler ve bilinçsiz diyet uygulayanlar."
          ],
          warnings: [
            "⚠️ **Bilinç Kapalıysa Sıvı Vermeyin:** Bilinci kapalı veya bulantısı olan hasta/yaralıya ağızdan sıvı verilmez.",
            "⚠️ **Korunma:** Şapka, güneş gözlüğü ve şemsiye kullanın; açık renkli hafif giysiler giyin; bol sıvı tüketin; direkt güneş ışığından kaçının."
          ],
          steps: [
            "**Serin Yere Alın:** Hasta serin ve havadar bir yere alınır.",
            "**Giysileri Çıkarın:** Giysileri çıkarılır.",
            "**Pozisyon Verin:** Sırt üstü yatırılarak kol ve bacaklar yükseltilir.",
            "**Sıvı Verin:** Bulantısı yoksa ve bilinci açıksa su ve tuz kaybını gidermek için 1 litre su, 1 çay kaşığı karbonat ve 1 çay kaşığı tuz karışımı ya da soda içirilir.",
            "**112'yi Arayın:** Durumu iyileşmiyorsa veya bilinci kapalıysa tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "frostbite",
          title: "Donmada İlkyardım",
          description:
              "Aşırı soğuğa bağlı doku hasarında donuk dereceleri (1-2-3) ve doğru ısınma ile ilkyardım adımları.",
          keywords: [
            "donma",
            "donuk",
            "soğuk",
            "kabarcık",
            "uyuşukluk",
            "siyah bölge",
            "ısınma"
          ],
          icon: Icons.ac_unit_rounded,
          gradientColors: [Color(0xFF0277BD), Color(0xFF01579B)],
          symptoms: [
            "**1. Derece Donuk:** En hafif şeklidir. Deride solukluk, soğukluk, uyuşukluk, halsizlik; daha sonra kızarıklık ve iğnelenme hissi oluşur.",
            "**2. Derece Donuk:** Zarar gören bölgede gerginlik hissi, ödem, şişkinlik, ağrı ve içi su dolu kabarcıklar (bül) oluşur. Su toplanması iyileşirken siyah kabuklara dönüşür.",
            "**3. Derece Donuk:** Dokuların geri dönülmez biçimde hasara uğramasıdır. Canlı deriden net hatlarıyla ayrılan siyah bir bölge oluşur."
          ],
          warnings: [
            "⚠️ **Ovmayın:** Donuk bölge kesinlikle ovulmaz; kendi kendine ısınması sağlanır.",
            "⚠️ **Kabarcık Patlatmayın:** Su toplamış bölgeler patlatılmaz; üzeri temiz bir bezle örtülür.",
            "⚠️ **Zorla Açmayın:** Eller yumruk yapılmışsa veya ayaklar büzülmüşse zorla açılmaya çalışılmaz; doğal pozisyonda tutulur."
          ],
          steps: [
            "**Ilık Ortama Alın:** Hasta/yaralı ılık bir ortama alınarak soğukla teması kesilir ve sakinleştirilir.",
            "**İstirahat:** Kesin istirahat aldırılır ve hareket ettirilmez.",
            "**Kuru Giysiler Giydirin:** Islak giysiler çıkarılır, kuru giysiler giydirilir.",
            "**Sıcak İçecek Verin:** Sıcak içecekler verilir.",
            "**Kabarcıkları Koruyun:** Su toplamış bölgeler patlatılmaz; üzeri temiz bir bezle örtülür. Donuk bölge ovulmaz.",
            "**Uzuvları Kaldırın ve 112'yi Arayın:** El ve ayaklar yukarı kaldırılır. Isınma sonrası hâlâ hissizlik varsa bezle bandaj yapılır. Tıbbi yardım istenir (112)."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Kırık, Çıkık ve Burkulmalarda İlkyardım",
    description:
        "Kapalı/açık kırık, burkulma ve çıkık belirtileri ile kol, bacak ve omurga için tespit yöntemleri.",
    icon: Icons.accessibility_new_rounded,
    gradientColors: [Color(0xFF37474F), Color(0xFF263238)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "fractures",
          title: "Kırıklarda İlkyardım",
          description:
              "Kapalı ve açık kırık türleri, kırık belirtileri, yol açabileceği olumsuz durumlar ve ilkyardım adımları.",
          keywords: [
            "kırık",
            "kapalı kırık",
            "açık kırık",
            "kemik",
            "şekil bozukluğu",
            "ödem",
            "tespit",
            "morarma"
          ],
          icon: Icons.accessibility_new_rounded,
          gradientColors: [Color(0xFF37474F), Color(0xFF263238)],
          symptoms: [
            "**Kapalı Kırık:** Kemik bütünlüğü bozulmuştur; ancak deri sağlamdır.",
            "**Açık Kırık:** Deri bütünlüğü bozulmuştur. Kırık uçları dışarı çıkabilir; beraberinde kanama ve enfeksiyon tehlikesi taşır.",
            "**Kırık Belirtileri:** Hareketle artan ağrı, şekil bozukluğu, hareket kaybı, ödem ve kanama nedeniyle morarma.",
            "**Olumsuz Durumlar:** Kırık yakınındaki damar, sinir ve kaslarda yaralanma ve sıkışma (kırık bölgede nabız alınamaması, solukluk, soğukluk); parçalı kırıklarda kanamaya bağlı şok."
          ],
          warnings: [
            "⚠️ **Hareket Ettirmeyin:** Hasta/yaralı hareket ettirilmez; sıcak tutulur.",
            "⚠️ **Parmakları Açıkta Bırakın:** Tespit ve sargı yapılırken parmaklar görünecek şekilde açıkta bırakılır; böylece parmaklardaki renk, hareket ve duyarlılık kontrol edilebilir.",
            "⚠️ **Açık Kırıkta:** Tespitten önce yara temiz bir bezle kapatılmalıdır."
          ],
          steps: [
            "**Hayati Tehlikeye Öncelik:** Hayatı tehdit eden yaralanmalara öncelik verilir.",
            "**Takıları Çıkarın:** Kol etkilenmişse yüzük ve saat gibi eşyalar çıkarılır; aksi takdirde gelişebilecek ödem doku hasarına yol açar.",
            "**Açık Kırıkta Yarayı Örtün:** Açık kırıklarda tespitten önce yara temiz bir bezle kapatılır.",
            "**Tespit Yapın:** Kırık şüphesi olan bölge, bir alt ve bir üst eklemi de içine alacak şekilde sert malzemeyle (sopa, tahta, karton) tespit edilir.",
            "**Nabzı ve Rengi Kontrol Edin:** Kırık bölgede sık aralıklarla nabız, derinin rengi ve ısısı kontrol edilir.",
            "**Uzvu Yukarıda Tutun ve 112'yi Arayın:** Kol ve bacaklar yukarıda tutulur. Tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "sprains",
          title: "Burkulmalarda İlkyardım",
          description:
              "Eklem yüzeylerinin anlık olarak ayrılmasıyla oluşan burkulmanın belirtileri ve sıkıştırıcı bandajla tespit adımları.",
          keywords: [
            "burkulma",
            "eklem",
            "ayak burkulması",
            "bileği",
            "şişlik",
            "kızarma",
            "bandaj",
            "istirahat"
          ],
          icon: Icons.sports_handball_rounded,
          gradientColors: [Color(0xFF00695C), Color(0xFF004D40)],
          symptoms: [
            "**Burkulma Tanımı:** Eklem yüzeylerinin anlık olarak ayrılmasıdır; zorlamalar sonucu oluşur.",
            "**Burkulma Belirtileri:** Burkulan bölgede ağrı, kızarma, şişlik ve işlev kaybı."
          ],
          warnings: [
            "⚠️ **Hareket Ettirmeyin:** Burkulan eklem hareket ettirilmez.",
            "⚠️ **Tıbbi Yardım:** Tıbbi yardım istenir (112)."
          ],
          steps: [
            "**Sıkıştırıcı Bandaj:** Sıkıştırıcı bir bandajla burkulan eklem tespit edilir.",
            "**Bölgeyi Yükseltin:** Şişliği azaltmak için bölge yukarı kaldırılır.",
            "**Hareket Ettirmeyin:** Burkulan eklem hareket ettirilmez.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "dislocations",
          title: "Çıkıklarda İlkyardım",
          description:
              "Eklem yüzeylerinin kalıcı olarak ayrılmasıyla oluşan çıkığın belirtileri ve yerine oturtmadan tespit adımları.",
          keywords: [
            "çıkık",
            "eklem",
            "omuz çıkığı",
            "şişlik",
            "işlev kaybı",
            "eklem bozukluğu",
            "tespit"
          ],
          icon: Icons.front_hand_rounded,
          gradientColors: [Color(0xFF4527A0), Color(0xFF311B92)],
          symptoms: [
            "**Çıkık Tanımı:** Eklem yüzeylerinin kalıcı olarak ayrılmasıdır. Kendiliğinden normal konumuna dönemez.",
            "**Çıkık Belirtileri:** Yoğun ağrı, şişlik ve kızarıklık, işlev kaybı ve eklem bozukluğu."
          ],
          warnings: [
            "⚠️ **Yerine Oturtmayın:** Çıkık yerine oturtulmaya çalışılmaz.",
            "⚠️ **Ağızdan Bir Şey Vermeyin:** Hasta/yaralıya ağızdan hiçbir şey verilmez.",
            "⚠️ **Nabız ve Renk Kontrolü:** Bölgede nabız, deri rengi ve ısısı kontrol edilir."
          ],
          steps: [
            "**Olduğu Gibi Tespit Edin:** Eklem aynen bulunduğu şekilde tespit edilir; düzeltilmeye çalışılmaz.",
            "**Yerine Oturtmayın:** Çıkık yerine oturtulmaya çalışılmaz.",
            "**Ağızdan Bir Şey Vermeyin:** Hasta/yaralıya ağızdan hiçbir şey verilmez.",
            "**Nabız ve Rengi Kontrol Edin:** Bölgede nabız, deri rengi ve ısısı kontrol edilir.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "immobilization",
          title: "Tespit Yöntemleri",
          description:
              "Kol, köprücük kemiği, pazı, dirsek, ön kol, pelvis, uyluk, diz kapağı, kaval kemiği ve bilek/ayak kırıklarında uygulanacak tespit teknikleri.",
          keywords: [
            "tespit",
            "kol askısı",
            "üçgen bandaj",
            "rulo sargı",
            "kırık tespiti",
            "pelvis",
            "uyluk",
            "bacak",
            "bilek",
            "ayak"
          ],
          icon: Icons.healing_rounded,
          gradientColors: [Color(0xFF1B5E20), Color(0xFF33691E)],
          symptoms: [
            "**Tespit Malzemeleri:** Üçgen sargı, rulo sargı, battaniye, hırka, eşarp, kravat ile tahta, karton gibi sert malzemeler kullanılır.",
            "**Tespit Kuralları:** Yaralı bölge sabit tutulmalı; yara varsa üzeri temiz bezle kapatılmalı; tespit edilecek bölge önce yumuşak malzemeyle kaplanmalı; bölge nasıl bulunduysa öyle tespit edilmeli, düzeltilmeye çalışılmamalıdır.",
            "**Eklem Kapsama Kuralı:** Tespit; kırık, çıkık ve burkulmanın üstündeki ve altındaki eklemleri de içerecek şekilde yapılmalıdır."
          ],
          warnings: [
            "⚠️ **Çok Sıkmayın:** Tespit şeritleri ve bandajlar çok sıkı bağlanmamalıdır; dolaşımı kesebilir.",
            "⚠️ **Parmaklar Görünür Olmalı:** Tespit sonrasında parmaklar her zaman görünür şekilde açıkta bırakılmalıdır.",
            "⚠️ **Düzeltme Yasak:** Yaralı bölge nasıl bulunduysa öyle tespit edilir; düzeltilmeye çalışılmaz."
          ],
          steps: [
            "**Kol ve Köprücük Kemiği Tespiti:** Koltuk altına yumuşak malzeme yerleştirilir. Üçgen bandaj gövde üzerine, tepesi dirsek tarafına gelecek şekilde yerleştirilir. El dirsek hizasında bükülü göğüs altına konur; bandajın iki ucu boyuna düğümlenir. Kol askısı desteği ile kol ve omuz eklemi vücuda yapışık biçimde sabitlenir.",
            "**Pazı Kemiği Tespiti:** Sert tespit malzemeleriyle yapılır. Kolun altına iki şerit geçirilir; kısa malzeme koltuk altından dirseği, uzun malzeme omuzla dirseği içine alacak şekilde yerleştirilerek şeritlerle bağlanır. Dirseği tespit için kol askısı takılır; omur tespiti için geniş kumaş şerit uygulanır.",
            "**Dirsek / Ön Kol / Bilek Tespiti:** Dirsek gerginse vücut boyunca yumuşak dolgulu malzemeyle tespit edilir; bükülmüşse kol askısıyla tespit edilir. Ön kol kırığında iki şerit geçirilerek sert malzeme parmak diplerinden dirseğe kadar iç ve dış yüzden konur, bağlanır; kol askısı takılır. Bilek ve el tarak kemiğinde yalnızca kol askısı yeterlidir.",
            "**Pelvis Kırığı Tespiti:** Her iki bacak arasına dolgu malzemesi konur. Sekiz şeklinde bandajla bilekler tespit edilir. Kalça-diz ve diz-bilek arasına dört bandaj düğümlenir; tüm düğümler aynı tarafta olmalıdır.",
            "**Uyluk Kemiği Tespiti:** Yaralı bacak yavaşça sağlam bacakla hizaya getirilir. Bacaklar arasına dolgu malzemesi konur; sekiz bandajla bilekler sabitlenir. Yedi kumaş şerit (bel, diz, bilek arkasına) yerleştirilir; koltuk altından ayağa kadar sert tespit malzemesi konarak ayaklardan yukarı doğru bağlanır.",
            "**Diz Kapağı / Kaval / Bilek-Ayak Tespiti:** Diz kapağı: Geniş bandajlarla iki bacak birleştirilir; sert malzeme (tabla) varsa kalçadan ayağa yerleştirilerek sekiz bandajla sarılır. Kaval kemiği: Uyluk tespitindeki gibi iç ve dış yandan sert malzeme kasıktan/kalçadan ayağa yerleştirilir. Bilek/ayak: Ayakkabı bağları çözülerek ayakkabı çıkarılmadan sekiz bandajla her iki ayak birlikte tespit edilir; bacaklar yukarıda tutulur."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Bilinç Bozukluklarında İlkyardım",
    description:
        "Bayılma, koma, havale, kan şekeri düşüklüğü ve kalp krizine bağlı bilinç bozukluklarında ilkyardım uygulamaları.",
    icon: Icons.psychology_rounded,
    gradientColors: [Color(0xFF4A148C), Color(0xFF311B92)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "unconsciousness",
          title: "Bayılma ve Koma (Bilinç Kaybı)",
          description:
              "Kısa süreli bayılma (senkop) ile uzun süreli bilinç kaybı (koma) nedenleri, belirtileri ve koma pozisyonu adımları.",
          keywords: [
            "bilinç",
            "bayılma",
            "senkop",
            "koma",
            "koma pozisyonu",
            "şok",
            "bilinç kaybı"
          ],
          icon: Icons.airline_seat_flat_rounded,
          gradientColors: [Color(0xFF5E35B1), Color(0xFF4527A0)],
          symptoms: [
            "**Bayılma (Senkop):** Kısa süreli, yüzeysel ve geçici bilinç kaybıdır. Beyne giden kan akışının azalması sonucu oluşur. Baş dönmesi, yüzde solgunluk, bacaklarda uyuşma, üşüme, terleme ve yere düşme ile kendini gösterir.",
            "**Koma:** Yutkunma ve öksürük gibi reflekslerin yok olması ile ortaya çıkan uzun süreli bilinç kaybıdır. Sesli ve ağrılı dürtülere tepki yoktur; idrar ve gaita kaçırma görülebilir.",
            "**Nedenleri:** Bayılma genellikle korku, heyecan, sıcak, havasızlık veya aniden ayağa kalkma ile olurken; koma şiddetli darbe, kafa travması, zehirlenme, diyabet veya karaciğer hastalıklarına bağlıdır."
          ],
          warnings: [
            "⚠️ **Yalnız Bırakmayın:** Bilinci kapalı olan hasta/yaralı asla yalnız bırakılmaz.",
            "⚠️ **Ağızdan Bir Şey Vermeyin:** Koma durumundaki kişiye ağızdan hiçbir yiyecek/içecek verilmez.",
            "⚠️ **Kusmaya Dikkat:** Kusma varsa kişi mutlaka yan pozisyonda tutulmalıdır."
          ],
          steps: [
            "**Bayılma Hissi (Baş Dönmesi):** Kişi sırt üstü yatırılır, ayakları 30 cm kaldırılır (şok pozisyonu); sıkan giysiler gevşetilir ve dinlenmesi sağlanır.",
            "**Bayılma Gerçekleşmişse:** Sırt üstü yatırılıp ayakları 30 cm kaldırılır; solunum yolu açıklığı kontrol edilir. Kusma varsa yan pozisyona alınır ve meraklılar uzaklaştırılır.",
            "**Bilinci Kapalıysa (Koma):** ABC değerlendirmesi yapılır; ağız içinde yabancı cisim kontrol edilir.",
            "**Koma Pozisyonu Verin:** Sesli ve ağrılı uyarıya tepki yoksa, hasta/yaralının karşı tarafındaki kolu omzuna, bacağı dik açı yapacak şekilde kıvrılır; omuz ve kalçadan tutularak bir hamlede yan çevrilir.",
            "**Destekleyin:** Üstteki bacak ve kol öne, alttaki bacak arkaya destek yapılarak baş, uzatılan kolun üzerine yan pozisyonda konur.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112) ve 3-5 dakika arayla solunum ve nabız kontrol edilerek yardım gelene kadar yanında beklenir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "seizures",
          title: "Havale ve Sara Krizi (Epilepsi)",
          description:
              "Sinir sistemindeki elektriksel boşalmalar sonucu oluşan ateşli havale ve sara krizinde güvenlik odaklı ilkyardım.",
          keywords: [
            "havale",
            "sara",
            "epilepsi",
            "kriz",
            "titreme",
            "ateş",
            "kasılma",
            "çene kilitlenmesi"
          ],
          icon: Icons.monitor_heart_rounded,
          gradientColors: [Color(0xFF00838F), Color(0xFF006064)],
          symptoms: [
            "**Ateşli Havale:** Genellikle 6 ay - 6 yaş arası çocuklarda, vücut sıcaklığının 38°C'nin üstüne çıkmasıyla oluşur.",
            "**Sara (Epilepsi) Krizi:** Normalde olmayan kokular alma, adale kasılmaları, ani bilinç kaybı ve yere yığılma ile başlar. 10-20 saniye nefes kesilebilir, morarma gözlenir.",
            "**Kriz Anı:** Aşırı tükürük salgılanması, altına kaçırma, dilini ısırma ve başını yere çarpma görülebilir. Kriz bitiminde hasta şaşkın ve uykuludur."
          ],
          warnings: [
            "⚠️ **Bağlamaya Çalışmayın:** Kriz geçiren hasta/yaralı kesinlikle bağlanmaya veya bastırılmaya çalışılmaz.",
            "⚠️ **Çeneyi Açmayın:** Kilitlenmiş çene açılmaya çalışılmaz.",
            "⚠️ **Madde Koklatmayın:** Yabancı madde koklatılmaz (soğan, kolonya vb.) ve ağızdan hiçbir şey verilmez."
          ],
          steps: [
            "**Ateşli Havalede:** Hasta önce ıslak havlu/çarşafa sarılır; ateş düşmüyorsa oda sıcaklığında küvete sokulur ve 112 aranır.",
            "**Sara Krizinde Güvenlik:** Olay yerindeki tehlikeler (trafik vb.) ve yaralanmaya neden olabilecek eşyalar uzaklaştırılır.",
            "**Süreci Kendi Haline Bırakın:** Krizin kendi sürecini tamamlaması beklenir; hastaya müdahale edilmez.",
            "**Başı Koruyun:** Başını çarpmasını engellemek için başının altına yumuşak bir malzeme konur.",
            "**Giysileri Gevşetin:** Sıkan giysiler gevşetilir, kusmaya karşı tedbirli olunur.",
            "**112'yi Arayın:** Kriz sonrasında tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "low_blood_sugar",
          title: "Kan Şekeri Düşüklüğü",
          description:
              "Uzun süre açlık, diyabet veya aşırı egzersiz sonucu aniden veya yavaş gelişen kan şekeri düşüklüğünde şeker takviyesi.",
          keywords: [
            "kan şekeri",
            "diyabet",
            "açlık",
            "terleme",
            "titreme",
            "şeker",
            "şuur kaybı"
          ],
          icon: Icons.bloodtype_rounded,
          gradientColors: [Color(0xFFC62828), Color(0xFF8E0000)],
          symptoms: [
            "**Ani Gelişen Belirtiler:** Korku, terleme, hızlı nabız, titreme, aniden acıkma, yorgunluk ve bulantı.",
            "**Yavaş Gelişen Belirtiler:** Baş ağrısı, görme bozukluğu, uyuşukluk, zayıflık, konuşma güçlüğü, kafa karışıklığı, sarsıntı ve şuur kaybı.",
            "**Nedenleri:** Şeker hastalığı tedavisi, uzun egzersizler, uzun süre aç kalma veya bağırsak ameliyatı geçirenlerde yemek sonrası olabilir."
          ],
          warnings: [
            "⚠️ **Bilinci Kapalıysa:** Bilinci kapalı olan hastaya asla ağızdan şeker veya sıvı verilmez.",
            "⚠️ **Fazla Şekerin Zararı Yoktur:** Durum kan şekeri yüksekliğinden kaynaklansa bile, fazladan şeker verilmesi düşük şeker durumunda oluşacak kalıcı beyin hasarından daha az zararlıdır."
          ],
          steps: [
            "**ABC Değerlendirmesi:** Hastanın yaşam bulguları değerlendirilir.",
            "**Bilinç Açık ve Kusmuyorsa:** Hastaya hemen ağızdan şeker veya şekerli içecekler verilir.",
            "**Takip Edin:** 15-20 dakika içinde belirtiler geçmiyorsa sağlık kuruluşuna gitmesi için yardım çağrılır.",
            "**Bilinç Kapalıysa:** Hastanın bilinci yerinde değilse koma pozisyonu verilir.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112) ve durum takip edilir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "heart_spasm",
          title: "Kalp Spazmı (Angina Pektoris)",
          description:
              "Fiziksel zorlanma veya heyecanla ortaya çıkan, göğüs ortasında başlayıp istirahatle geçen kısa süreli kalp spazmı.",
          keywords: [
            "kalp spazmı",
            "angina",
            "göğüs ağrısı",
            "kısa süreli",
            "dinlenme",
            "kalp"
          ],
          icon: Icons.favorite_border_rounded,
          gradientColors: [Color(0xFFEF6C00), Color(0xFFE65100)],
          symptoms: [
            "**Belirtiler:** Sıkıntı veya nefes darlığı olur. Ağrı genellikle göğüs ortasında başlar; kollara, boyuna, sırta ve çeneye yayılır.",
            "**Süresi:** Kısa sürelidir; ağrı yaklaşık 5-10 dakika kadar sürer.",
            "**Tetikleyiciler:** Sıklıkla fiziksel hareket, zorlanma, heyecan, üzüntü veya fazla yemek yeme sonucu ortaya çıkar.",
            "**Geçişi:** Ağrı, istirahat ile durur; istirahat halindeyken görülmesi ciddi bir durumu gösterir. Nefes alıp vermekle ağrının şekli değişmez."
          ],
          warnings: [
            "⚠️ **İlaç Kullanımı:** Hasta kendi kalp ilaçlarını kullanıyorsa, almasına yardımcı olun.",
            "⚠️ **Efor Sarf Etmemeli:** Hasta kesinlikle hareket ettirilmemeli ve efor sarf etmemelidir."
          ],
          steps: [
            "**Yaşamsal Bulguları Kontrol Edin:** Hastanın ABC'si (Havayolu, Solunum, Dolaşım) kontrol edilir.",
            "**Dinlenmeye Alın:** Hasta hemen dinlenmeye alınır ve sakinleştirilir.",
            "**Pozisyon Verin:** Yarı oturur pozisyon verilir (solunumu rahatlatır).",
            "**İlacını Verin:** Kullandığı ilaçları varsa almasına yardım edilir.",
            "**112'yi Arayın:** Yardım istenerek (112) sağlık kuruluşuna sevki sağlanır.",
            "**İzleyin:** Yol boyunca ve ambulans gelene kadar yaşam bulguları izlenir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "heart_attack",
          title: "Kalp Krizi (Miyokart Enfarktüsü)",
          description:
              "Ölüm korkusu, terleme ve şiddetli/uzun süreli göğüs ağrısı ile karakterize hayati tehlike taşıyan kalp krizi durumu.",
          keywords: [
            "kalp krizi",
            "miyokart enfarktüsü",
            "ölüm korkusu",
            "şiddetli ağrı",
            "terleme",
            "kravat bölgesi"
          ],
          icon: Icons.favorite_rounded,
          gradientColors: [Color(0xFFB71C1C), Color(0xFF7F0000)],
          symptoms: [
            "**Şiddetli Belirtiler:** Hasta ciddi bir ölüm korkusu ve yoğun sıkıntı hisseder. Terleme, mide bulantısı ve kusma görülür.",
            "**Ağrının Yeri:** Ağrı göğüs veya mide boşluğunda, sıklıkla 'kravat bölgesinde' görülür; omuzlara, boyuna, çeneye ve sol kola yayılır.",
            "**Süresi:** Kalp spazmına göre daha şiddetli ve uzun sürelidir.",
            "**Karıştırılma Riski:** En çok hazımsızlık, gaz sancısı veya kas ağrısı şeklinde belirti verir. Aksi ispat edilene kadar gaz/kas ağrıları kalp krizi varsayılmalıdır."
          ],
          warnings: [
            "⚠️ **Hareket Kesinlikle Yasak:** Kalp krizi geçiren kişi kesinlikle yürütülmez ve hareket ettirilmez.",
            "⚠️ **Hemen Yardım:** Zaman hayati önem taşır; derhal 112 aranmalıdır.",
            "⚠️ **Yalnız Bırakmayın:** Bilinç kaybı veya solunum durmasına karşı hasta asla yalnız bırakılmaz."
          ],
          steps: [
            "**Yaşamsal Bulguları Kontrol Edin:** Hastanın ABC'si (Havayolu, Solunum, Dolaşım) hızlıca kontrol edilir.",
            "**Kesin Dinlenme:** Hasta olduğu yerde, hareket ettirilmeden dinlenmeye alınır ve sakinleştirilir.",
            "**Yarı Oturur Pozisyon:** Nefes almasını kolaylaştırmak için yarı oturur pozisyon verilir.",
            "**Giysileri Gevşetin:** Kravat, yaka, kemer gibi sıkan giysiler gevşetilir.",
            "**İlacını Verin:** Hastanın daha önceden doktor tarafından verilmiş kalp ilacı varsa almasına yardımcı olunur.",
            "**Hemen 112'yi Arayın:** Derhal 112 aranarak durumun kalp krizi olabileceği bildirilir ve yaşam bulguları sürekli takip edilir."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Zehirlenmelerde İlkyardım",
    description:
        "Sindirim, solunum (şofben/karbon monoksit) ve cilt yoluyla zehirlenmelerde genel kurallar ve ilkyardım uygulamaları.",
    icon: Icons.science_rounded,
    gradientColors: [Color(0xFF33691E), Color(0xFF1B5E20)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "digestive_poisoning",
          title: "Sindirim Yoluyla Zehirlenmeler",
          description:
              "Bozuk besin, ilaç veya kimyasal madde gibi zehirlerin yutulmasıyla oluşan zehirlenmelerde kusturmama kuralı ve ilkyardım.",
          keywords: [
            "zehirlenme",
            "sindirim",
            "mide",
            "ilaç",
            "bozuk besin",
            "kusturma",
            "kimyasal"
          ],
          icon: Icons.restaurant_rounded,
          gradientColors: [Color(0xFF558B2F), Color(0xFF33691E)],
          symptoms: [
            "**En Sık Rastlanan Yol:** Zehirlenmelerin en sık görülen şeklidir. Genellikle kimyasal maddeler, zehirli mantarlar, bozuk besinler, ilaç veya aşırı alkol ile oluşur.",
            "**Belirtiler:** Bulantı, kusma, karın ağrısı, gaz, şişkinlik ve ishal gibi sindirim sistemi bozuklukları görülür."
          ],
          warnings: [
            "⚠️ **Kusturmayın:** Hasta kesinlikle kusturulmaya çalışılmaz! Özellikle yakıcı maddelerin içildiği durumlarda kusturmak çok daha büyük hasara yol açar.",
            "⚠️ **Ağız Temizliği:** Ağız zehirli maddeyle temas etmişse su ile çalkalanır.",
            "⚠️ **Bilgi Toplama:** 112'ye yardımcı olmak için zehirli maddenin türü, hastanın ilacı/uyuşturucusu olup olmadığı ve saati mutlaka not edilmelidir."
          ],
          steps: [
            "**Bilinç Kontrolü:** Hastanın bilinç kontrolü yapılır.",
            "**Ağzı Çalkalayın:** Ağız zehirli madde ile temas etmişse su ile çalkalanır; ele temas etmişse eller sabunlu suyla yıkanır.",
            "**Yaşam Bulgularını Değerlendirin:** ABC (Havayolu, Solunum, Dolaşım) değerlendirilir.",
            "**Belirtileri İzleyin:** Kusma, bulantı, ishal gibi belirtiler değerlendirilir.",
            "**Koma Pozisyonu Verin:** Bilinç kaybı varsa koma pozisyonu verilir ve üstü örtülür.",
            "**112'yi Arayın ve Bilgi Verin:** Tıbbi yardım istenir (112); zehirlenme ile ilgili toplanan bilgiler (madde türü, zamanı vb.) sağlık ekibine iletilir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "respiratory_poisoning",
          title: "Solunum Yoluyla Zehirlenmeler",
          description:
              "Karbon monoksit, şofben kazaları ve kimyasal gaz zehirlenmelerinde ortamı havalandırma ve güvenli müdahale.",
          keywords: [
            "zehirlenme",
            "solunum",
            "gaz",
            "şofben",
            "karbon monoksit",
            "havalandırma",
            "tüp kaçağı"
          ],
          icon: Icons.air_rounded,
          gradientColors: [Color(0xFF00838F), Color(0xFF006064)],
          symptoms: [
            "**Nedenleri:** Genellikle karbon monoksit (tüp kaçakları, şofben, bütan gaz sobaları), kuyu veya kayalarda biriken gazlar, klor, yapıştırıcılar ve boyalarla oluşur.",
            "**Şofben ve Karbon Monoksit:** Ortamdaki oksijenin hızla tükenmesine bağlıdır. Karbon monoksit renksiz ve kokusuzdur.",
            "**Belirtiler:** Nefes darlığı, baş ağrısı/dönmesi, yorgunluk, bulantı, ciltte kısa süreli kiraz kırmızısı renk değişimi, solunum ve kalp durması."
          ],
          warnings: [
            "⚠️ **Kendinizi Koruyun:** Müdahale eden ilkyardımcı kendini korumalıdır (maske veya ıslak bez kullanmalıdır).",
            "⚠️ **Elektrik Kullanmayın:** Patlama riskine karşı elektrik düğmeleri (ışık, alet) kesinlikle kullanılmaz.",
            "⚠️ **İtfaiye:** Yoğun duman varsa hasta dışarı iple çekilerek çıkarılır ve derhal 110 (İtfaiye) aranır."
          ],
          steps: [
            "**Ortamı Havalandırın:** Cam ve kapı açılarak ortam derhal havalandırılır veya hasta temiz havaya çıkarılır.",
            "**Güvenliğe Dikkat Edin:** Elektrik düğmelerine dokunmayın; kendinizi korumak için maske veya ıslak bez kullanın.",
            "**ABC Değerlendirmesi:** Yaşamsal belirtiler değerlendirilir (ABC).",
            "**Yarı Oturur Pozisyon:** Nefes almasını kolaylaştırmak için hasta yarı oturur pozisyonda tutulur.",
            "**Koma Pozisyonu:** Hastanın bilinci kapalı ise koma pozisyonu verilir.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "skin_poisoning",
          title: "Cilt Yoluyla Zehirlenmeler",
          description:
              "Zirai ilaçlar, saç boyaları veya diğer kimyasalların ciltten emilmesiyle oluşan zehirlenmelerde bol suyla yıkama adımları.",
          keywords: [
            "zehirlenme",
            "cilt",
            "deri",
            "kimyasal madde",
            "temas",
            "yıkama",
            "zirai ilaç"
          ],
          icon: Icons.back_hand_rounded,
          gradientColors: [Color(0xFFE65100), Color(0xFFBF360C)],
          symptoms: [
            "**Nasıl Oluşur:** Zehirli madde vücuda direkt deri aracılığı ile girer.",
            "**Nedenleri:** İlaç enjeksiyonları, saç boyaları, zirai ilaçlar gibi zehirli maddelerin deriden emilmesiyle oluşur. (Böcek ve hayvan ısırmaları da bu gruba girer ancak ayrı ele alınır.)"
          ],
          warnings: [
            "⚠️ **Teması Kesin:** Kirli madde vücuttan ne kadar çabuk uzaklaştırılırsa, o kadar az miktarda kana karışır.",
            "⚠️ **Giysiler:** Zehir bulaşmış giysiler derhal çıkarılmalıdır.",
            "⚠️ **Kendinizi Koruyun:** İlkyardımcı kendi ellerinin zehirle temasını önlemelidir."
          ],
          steps: [
            "**ABC Değerlendirmesi:** Yaşam bulguları değerlendirilir.",
            "**Kendinizi Koruyun:** Ellerin zehirli madde ile teması önlenmelidir (eldiven vb. kullanın).",
            "**Giysileri Çıkarın:** Zehir bulaşmış tüm giysiler çıkartılır.",
            "**Bol Suyla Yıkayın:** Deri en az 15-20 dakika boyunca bol suyla yıkanarak zehirli maddeden arındırılır.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Hayvan Isırmalarında İlkyardım",
    description:
        "Kedi, köpek, arı, akrep, yılan ve deniz canlıları sokmalarında hızlı müdahale adımları.",
    icon: Icons.pets_rounded,
    gradientColors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "cat_dog_bites",
          title: "Kedi ve Köpek Isırmaları",
          description: "Kedi ve köpek ısırmalarında uygulanacak acil ilkyardım adımları.",
          keywords: ["kedi", "köpek", "ısırma", "kuduz", "yıkama", "tetanos"],
          icon: Icons.pets_rounded,
          gradientColors: [Color(0xFF795548), Color(0xFF3E2723)],
          symptoms: [],
          warnings: [
            "⚠️ **Aşı Uyarısı:** Hasta kuduz ve/veya tetanos aşısı için mutlaka uyarılmalıdır."
          ],
          steps: [
            "**Yaşam Bulguları:** Hasta/yaralı yaşamsal bulgular (ABC) yönünden değerlendirilir.",
            "**Yarayı Yıkayın:** Hafif yaralanmalarda yara 5 dakika süreyle sabun ve soğuk suyla yıkanır.",
            "**Yarayı Örtün:** Yaranın üstü temiz bir bezle kapatılır.",
            "**Kanamayı Durdurun:** Ciddi yaralanma ve kanama varsa yaraya temiz bir bezle basınç uygulanarak kanama durdurulur.",
            "**112'yi Arayın:** Derhal tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "bee_stings",
          title: "Arı Sokmaları",
          description: "Arı sokmasında arının iğnesinin çıkarılması ve soğuk uygulama adımları.",
          keywords: ["arı", "sokma", "iğne", "buz", "alerji"],
          icon: Icons.bug_report_rounded,
          gradientColors: [Color(0xFFFBC02D), Color(0xFFF57F17)],
          symptoms: [],
          warnings: [
            "⚠️ **Alerji Riski:** Ağız içi sokmalarında ve alerji hikayesi olanlarda derhal tıbbi yardım istenir."
          ],
          steps: [
            "**Bölgeyi Yıkayın:** Yaralı bölge yıkanır.",
            "**İğneyi Çıkarın:** Derinin üzerinden görülüyorsa arının iğnesi dikkatlice çıkarılır.",
            "**Soğuk Uygulama:** Şişliği ve ağrıyı azaltmak için soğuk uygulama (buz) yapılır.",
            "**Ağız İçi Sokması:** Eğer ağızdan sokmuşsa ve solunumu güçleştiriyorsa buz emmesi sağlanır.",
            "**112'yi Arayın:** Alerji durumu varsa veya solunum güçlüğü çekiyorsa tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "scorpion_stings",
          title: "Akrep Sokmaları",
          description: "Akrep sokmalarında bandaj uygulaması ve yaranın hareket ettirilmemesi.",
          keywords: ["akrep", "sokma", "bandaj", "hareket", "soğuk uygulama"],
          icon: Icons.pest_control_rounded,
          gradientColors: [Color(0xFFD84315), Color(0xFFBF360C)],
          symptoms: [],
          warnings: [
            "⚠️ **Müdahale Etmeyin:** Yara üzerine hiçbir girişim (kesme, emme vb.) yapılmaz."
          ],
          steps: [
            "**Hareket Ettirmeyin:** Sokmanın olduğu bölge hareket ettirilmez.",
            "**Yatar Pozisyon:** Hasta yatar pozisyonda tutulur.",
            "**Soğuk Uygulama:** Yaraya soğuk uygulama yapılır.",
            "**Bandaj Uygulayın:** Kan dolaşımını engellemeyecek şekilde (sıkı olmayan) bandaj uygulanır.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "snake_bites",
          title: "Yılan Sokmaları",
          description: "Yılan sokmasında dolaşımı engellemeyecek şekilde bandaj uygulaması.",
          keywords: ["yılan", "sokma", "zehir", "bandaj", "turnike", "soğuk"],
          icon: Icons.gesture_rounded,
          gradientColors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          symptoms: [],
          warnings: [
            "⚠️ **Turnike Yasak:** Turnike kesinlikle uygulanmaz.",
            "⚠️ **Emmeyin:** Yara üzerine herhangi bir girişimde bulunulmaz (yara kesinlikle emilmez)."
          ],
          steps: [
            "**Dinlenmeye Alın:** Hasta sakinleştirilip, dinlenmesi sağlanır.",
            "**Yarayı Yıkayın:** Yara su ile yıkanır.",
            "**Eşyaları Çıkarın:** Yaraya yakın bölgede baskı yapabilecek yüzük, bilezik vb. eşyalar çıkarılır.",
            "**Baskı veya Bandaj:** Yara baş veya boyundaysa çevresine baskı uygulanır; kol ve bacaklarda ise yara üstünden dolaşımı engellemeyecek şekilde bandaj sarılır.",
            "**Soğuk Uygulama:** Yaraya soğuk uygulama yapılır.",
            "**112'yi Arayın:** Yaşamsal bulgular izlenerek tıbbi yardım istenir (112)."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "marine_animal_stings",
          title: "Deniz Canlıları Sokması",
          description: "Deniz canlıları sokmalarında sıcak uygulama ve batan dikeni çıkarma adımları.",
          keywords: ["deniz", "canlı", "sokma", "diken", "sıcak uygulama", "ovma"],
          icon: Icons.sailing_rounded,
          gradientColors: [Color(0xFF0277BD), Color(0xFF01579B)],
          symptoms: [],
          warnings: [
            "⚠️ **Ovmayın:** Etkilenen bölge kesinlikle ovulmamalıdır."
          ],
          steps: [
            "**Hareket Ettirmeyin:** Yaralı bölge hareket ettirilmez.",
            "**Dikeni Çıkarın:** Batan diken varsa ve görünüyorsa çıkartılır.",
            "**Sıcak Uygulama:** Zehrin etkisini azaltmak için yaraya sıcak uygulama yapılır.",
            "**Sağlık Kuruluşuna Gidin:** Belirtiler şiddetliyse veya devam ediyorsa sağlık kuruluşuna gidilir."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Yabancı Cisim Kaçması",
    description: "Göz, kulak ve buruna yabancı cisim kaçması durumlarında uygulanacak basit ve güvenli ilkyardım adımları.",
    icon: Icons.face_retouching_natural_rounded,
    gradientColors: [Color(0xFF00695C), Color(0xFF004D40)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "eye_foreign_body",
          title: "Göze Yabancı Cisim Kaçması",
          description: "Toz veya batan/metal cisimlerin göze kaçmasında yapılacaklar.",
          keywords: ["göz", "yabancı cisim", "toz", "metal", "batma", "ovma"],
          icon: Icons.remove_red_eye_rounded,
          gradientColors: [Color(0xFF00796B), Color(0xFF004D40)],
          symptoms: [],
          warnings: [
            "⚠️ **Ovmayın:** Göz kesinlikle ovulmamalıdır.",
            "⚠️ **Dokunmayın:** Batan bir cisim veya metal kaçmışsa göze hiçbir şekilde dokunulmaz."
          ],
          steps: [
            "**Toz ise Kırpıştırın:** Toz gibi küçük maddelerde göze ışığa doğru bakılarak alt ve üst kapak içi kontrol edilir, hastaya gözünü kırpıştırması söylenir.",
            "**Bezle Alın:** Gözün içinde toz görünüyorsa nemli temiz bir bezle çıkarılmaya çalışılır.",
            "**Metal veya Batan Cisim:** Bir cisim batması varsa ya da metal kaçmışsa hasta yerinden oynatılmaz ve göze asla dokunulmaz.",
            "**112'yi Arayın:** Cisim çıkmıyorsa veya batan cisimse tıbbi yardım istenir (112) ve bir göz uzmanına gidilmesi sağlanır."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "ear_foreign_body",
          title: "Kulağa Yabancı Cisim Kaçması",
          description: "Kulağa yabancı cisim kaçmasında sıvı ve delici alet yasağı.",
          keywords: ["kulak", "yabancı cisim", "delici", "su", "müdahale"],
          icon: Icons.hearing_rounded,
          gradientColors: [Color(0xFF0277BD), Color(0xFF01579B)],
          symptoms: [],
          warnings: [
            "⚠️ **Delici Cisim:** Kesinlikle sivri ve delici bir cisimle müdahale edilmez.",
            "⚠️ **Su Değdirmeyin:** Kulağa su değdirilmez (cismin şişmesine yol açabilir)."
          ],
          steps: [
            "**Müdahale Etmeyin:** Kulağa sivri alet, çubuk vb. sokarak çıkarmaya çalışmayın.",
            "**Su Yasağı:** Cisim türü bilinmiyorsa şişmemesi için su değdirmeyin.",
            "**112'yi Arayın:** Çıkarmaya çalışmadan tıbbi yardım istenir (112) veya bir sağlık kuruluşuna başvurulur."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "nose_foreign_body",
          title: "Buruna Yabancı Cisim Kaçması",
          description: "Buruna yabancı cisim kaçmasında sümkürterek çıkarma adımı.",
          keywords: ["burun", "yabancı cisim", "sümkürme", "nefes"],
          icon: Icons.airline_seat_recline_normal_rounded,
          gradientColors: [Color(0xFFD84315), Color(0xFFBF360C)],
          symptoms: [],
          warnings: [],
          steps: [
            "**Kuvvetli Nefes Verme:** Burun duvarına (açık olan tarafa) bastırarak, tıkalı delikten kuvvetli bir nefes verme (sümkürme) ile cismin atılması sağlanır.",
            "**Zorlamayın:** Cisim çıkmıyorsa yabancı bir aletle (cımbız vb.) çıkarmaya çalışıp daha geriye itmeyin.",
            "**112'yi Arayın:** Çıkmazsa hemen tıbbi yardım istenir (112) veya sağlık kuruluşuna gidilir."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Boğulmalarda İlkyardım",
    description: "Genel boğulma nedenleri, belirtileri ve suda boğulmalara yönelik özel müdahale teknikleri.",
    icon: Icons.waves_rounded,
    gradientColors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "general_drowning",
          title: "Genel Boğulmalar",
          description: "Dokulara yeterli oksijen gitmemesi sonucu oluşan boğulmaların genel belirtileri ve ilkyardımı.",
          keywords: ["boğulma", "oksijen", "nefes", "morarma", "bilinç"],
          icon: Icons.air_rounded,
          gradientColors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          symptoms: [
            "**Tanım:** Vücuttaki dokulara yeterli oksijen gitmemesi sonucu dokularda bozulma meydana gelmesidir.",
            "**Nedenleri:** Bayılma sonucu dilin geriye kayması, nefes borusuna sıvı dolması, yabancı cisim kaçması, asılma, gazla zehirlenme veya akciğer zedelenmesi.",
            "**Belirtileri:** Nefes almada güçlük; gürültülü, hızlı ve derin solunum; ağızda köpüklenme; dudak ve tırnaklarda morarma; genel sıkıntı ve bayılma."
          ],
          warnings: [
            "⚠️ **Zaman Kaybetmeyin:** Yaşamsal bulgular durmuşsa derhal temel yaşam desteğine başlanmalıdır."
          ],
          steps: [
            "**Nedeni Ortadan Kaldırın:** Boğulma nedeni (gaz, asılma vb.) hızla ortadan kaldırılır.",
            "**Bilinç Kontrolü:** Hastanın bilinç kontrolü yapılır.",
            "**ABC Değerlendirmesi:** Yaşamsal bulgular değerlendirilir.",
            "**Temel Yaşam Desteği:** Solunum durmuşsa derhal temel yaşam desteği (suni solunum ve kalp masajı) sağlanır.",
            "**112'yi Arayın:** Derhal tıbbi yardım istenir (112) ve yaşam bulguları izlenir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "water_drowning",
          title: "Suda Boğulmalar",
          description: "Suda boğulmalarda su içinde solunum ve suya atlama travmalarına karşı özel uyarılar.",
          keywords: ["su", "boğulma", "suni solunum", "soğuk su", "omurga travması"],
          icon: Icons.pool_rounded,
          gradientColors: [Color(0xFF006064), Color(0xFF00838F)],
          symptoms: [
            "**Soğuk Su Etkisi:** Suda boğulanlarda, özellikle soğuk havalarda 20-30 dakika geçse bile yapay solunum ve kalp masajına başlanmalıdır.",
            "**Su Yutulması:** Boğulma sırasında nefes borusu girişinin kasılmasına bağlı olarak çok az miktarda su akciğerlere girer."
          ],
          warnings: [
            "⚠️ **Omurga Travması Riski:** Suya atlama sonucu boğulma riskinin yanı sıra omurga kırıkları akla gelmelidir. Suda baş çok fazla arkaya itilmemelidir.",
            "⚠️ **Hızlı Müdahale:** Su içerisinde iken suni solunuma başlanabilir."
          ],
          steps: [
            "**Su İçinde Solunum:** Ağızdan ağza ya da buruna solunumun suda yaptırılması mümkündür; eğer güvenliyse su içerisinde iken başlanmalıdır.",
            "**Sığ Suya Çekin:** Derin sularda müdahale zor olacağından hasta/yaralı hızla sığ suya doğru çekilir.",
            "**Baş-Boyun Eksenini Koruyun:** Omurga kırığı riski nedeniyle baş çok fazla arkaya itilmez, dikkatle taşınır.",
            "**Temel Yaşam Desteği:** Karaya çıkarıldıktan sonra solunum ve nabız yoksa derhal Temel Yaşam Desteğine başlanır.",
            "**112'yi Arayın:** Tıbbi yardım istenir (112)."
          ],
        ),
      ),
    ],
  ),
  FirstAidCategory(
    title: "Hasta/Yaralı Taşıma Teknikleri",
    description: "İlkyardımcı güvenliği, Rentek manevrası, kısa mesafe taşıma ve sedye kullanım teknikleri.",
    icon: Icons.transfer_within_a_station_rounded,
    gradientColors: [Color(0xFF4E342E), Color(0xFF3E2723)],
    items: [
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "transport_general",
          title: "Taşıma Genel Kuralları",
          description: "Taşıma sırasında ilkyardımcının kendini koruması ve omurga sağlığı için genel prensipler.",
          keywords: ["taşıma", "kural", "omurga", "ağırlık", "destek", "hareket"],
          icon: Icons.rule_rounded,
          gradientColors: [Color(0xFF5D4037), Color(0xFF3E2723)],
          symptoms: [
            "**Temel Kural:** Olağanüstü bir tehlike yoksa hasta/yaralının yeri değiştirilmemeli ve dokunulmamalıdır."
          ],
          warnings: [
            "⚠️ **Kendi Sağlığınızı Koruyun:** İlkyardımcı taşıma sırasında kendi sağlığını riske sokmamalıdır.",
            "⚠️ **Omurgayı Koruyun:** Hasta/yaralı baş-boyun-gövde ekseni esas alınarak en az 6 destek noktasından kavranmalı ve az hareket ettirilmelidir."
          ],
          steps: [
            "**Yakın Çalışın:** Hasta/yaralıya yakın mesafede çalışılmalı ve uzun/kuvvetli kas grupları kullanılmalıdır.",
            "**Dizleri Bükün:** Sırtın gerginliğini korumak için dizler ve kalçalar bükülmeli, ağırlık kalça kaslarına verilerek kalkılmalıdır.",
            "**Düzgün Yürüyün:** Baş her zaman düz tutulmalı; yavaş, düzgün ve omuz genişliğini aşmayan adımlarla yürünmelidir.",
            "**Komut Verin:** Tüm hareketleri yönlendirecek sorumlu bir kişi (baş/boyun kısmını tutan) olmalı ve 'kaldırıyoruz' gibi komutlar vermelidir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "rentek_maneuver",
          title: "Araçtan Çıkarma (Rentek Manevrası)",
          description: "Kaza geçirmiş yaralıyı, yangın/patlama tehlikesi varsa omuriliğine zarar vermeden çıkarma yöntemi.",
          keywords: ["rentek", "araç", "kaza", "çıkarma", "omurilik", "patlama", "yangın"],
          icon: Icons.directions_car_rounded,
          gradientColors: [Color(0xFFC62828), Color(0xFF8E0000)],
          symptoms: [],
          warnings: [
            "⚠️ **Sadece Tehlike Varsa:** Rentek manevrası sadece solunum durması, yangın tehlikesi veya patlama gibi acil ve tehlikeli durumlarda uygulanır."
          ],
          steps: [
            "**Çevreyi Değerlendirin:** Kaza ortamı değerlendirilir, yangın/patlama tehlikesi belirlenir ve güvenlik sağlanır.",
            "**Bilinç ve Solunum Kontrolü:** Omuzlarına dokunarak bilinci kontrol edilir, 112 aratılır ve göğüs hareketleri izlenerek solunum kontrolü yapılır.",
            "**Ayakları Kontrol Edin:** Hasta/yaralının ayaklarının pedala sıkışmadığından emin olunur ve emniyet kemeri açılır.",
            "**Boynu Tespit Edin:** Yan taraftan yaklaşarak bir elle kolu, diğer elle çenesi kavranarak boynu (hafif hareketle) tespit edilir.",
            "**Dışarı Çekin:** Baş-boyun-gövde hizasını kesinlikle bozmadan araçtan dışarı doğru çekilir.",
            "**Yere Bırakın:** Hasta/yaralı yavaşça yere veya sedyeye yerleştirilir."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "short_distance_transport",
          title: "Sürükleme ve Kısa Mesafe Taşıma",
          description: "Dar alanlarda sürükleme ile kucakta, sırtta ve itfaiyeci yöntemiyle taşıma teknikleri.",
          keywords: ["sürükleme", "kucak", "sırt", "itfaiyeci", "altın beşik", "taşıma"],
          icon: Icons.transfer_within_a_station_rounded,
          gradientColors: [Color(0xFFEF6C00), Color(0xFFE65100)],
          symptoms: [],
          warnings: [
            "⚠️ **Ağırlık Kapasitesi:** İlkyardımcının fiziksel kapasitesi her zaman göz önünde bulundurulmalıdır."
          ],
          steps: [
            "**Sürükleme (Çok Kilolu / Dar Alan):** Ayak bileklerinden veya koltuk altından tutarak sürüklenir; mümkünse battaniye kullanılır.",
            "**Kucakta Taşıma:** Bilinci açık çocuklar ve hafif yetişkinler için bir elle diz altından, diğer elle sırtından kavranarak taşınır.",
            "**İtfaiyeci Yöntemi (Omuzda):** Yürüyemeyen veya bilinci kapalı kişiler için sağ kol bacakların arasından geçirilerek yaralı omuza alınır, boştaki kolla engeller aşılır.",
            "**Altın Beşik:** İki ilkyardımcı ile eller üzerinde kilit oluşturularak bilinçli hasta/yaralı taşınır.",
            "**Sandalye İle Taşıma:** Merdiven inip çıkarken iki kişiyle sandalyenin ön ayakları ve arka sırtlığından tutularak taşınır."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "stretcher_placement",
          title: "Sedyeye Yerleştirme Teknikleri",
          description: "Kaşık, köprü ve karşılıklı kaldırma teknikleriyle hastayı güvenli şekilde sedyeye alma.",
          keywords: ["sedye", "yerleştirme", "kaşık", "köprü", "karşılıklı"],
          icon: Icons.airline_seat_flat_rounded,
          gradientColors: [Color(0xFF00838F), Color(0xFF006064)],
          symptoms: [],
          warnings: [
            "⚠️ **Senkronizasyon:** Tüm ilkyardımcılar sorumlu kişinin komutuyla aynı anda, senkronize hareket etmelidir."
          ],
          steps: [
            "**Kaşık Tekniği (Tek Taraftan Ulaşım):** Üç ilkyardımcı yaralının tek tarafında diz çöker, ellerini vücudun altından geçirip yaralıyı kucaklayarak dizlerinin üzerine, oradan da sedyeye koyarlar.",
            "**Köprü Tekniği (İki Taraftan Ulaşım):** Dört kişiyle yapılır; üç kişi yaralının üstüne bacaklarını açıp çömelerek hastayı kaldırır, dördüncü kişi sedyeyi bacakların arasından iter.",
            "**Karşılıklı Kaldırma (Omurga Şüphesi):** Üç kişiyle yapılır; iki kişi göğüs hizasında karşılıklı, üçüncü kişi dizlerde durur. Baş-boyun ekseni kollarla sabitlenerek yaralı düz olarak kaldırılıp sedyeye konur."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "stretcher_transport",
          title: "Sedye ile Taşıma Kuralları",
          description: "Sedyeyle taşıma yaparken düşmeyi önleme, yatay konum ve adımlama kuralları.",
          keywords: ["sedye", "taşıma", "2 kişi", "4 kişi", "yatay", "adım"],
          icon: Icons.supervisor_account_rounded,
          gradientColors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          symptoms: [],
          warnings: [
            "⚠️ **Bağlama Şartı:** Hasta/yaralı düşmesini önlemek için mutlaka sedyeye bağlanmalıdır."
          ],
          steps: [
            "**Yatay Konum:** Sedye daima yatay konumda tutulmalı ve yaralının başı gidiş yönünde olmalıdır.",
            "**Güçlü Kişi Başta:** Güçlü olan ilkyardımcı her zaman hasta/yaralının baş kısmında durmalıdır.",
            "**Adımlama (Sarsıntıyı Önlemek):** Öndeki ilkyardımcı sağ, arkadaki ilkyardımcı sol ayağı ile yürümeye başlamalıdır.",
            "**4 Kişiyle Taşıma:** Yol uzun, zorlu ve engelli ise sedye mutlaka 4 kişiyle; baş ve ayak kısımlarının yanlarından tutularak komut eşliğinde taşınmalıdır.",
            "**Merdivenler:** Merdiven veya yokuş inip çıkarken ayak tarafındakiler sedyeyi omuz, baş tarafındakiler uyluk hizasında tutarak yataylığı korumalıdır."
          ],
        ),
      ),
      FirstAidCategoryItem(
        topic: FirstAidTopic(
          id: "stretcher_making",
          title: "Geçici Sedye Oluşturma",
          description: "Battaniye ve kiriş kullanarak acil durumlarda geçici bir sedye hazırlama.",
          keywords: ["sedye", "yapımı", "battaniye", "kiriş", "geçici"],
          icon: Icons.hardware_rounded,
          gradientColors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          symptoms: [],
          warnings: [],
          steps: [
            "**Sadece Battaniye İle:** Tek bir battaniye yere serilir, kenarları sıkıca rulo yapılır ve yaralı üzerine yatırılarak kısa mesafede güvenle taşınabilir.",
            "**Battaniye ve 2 Kiriş İle:** Battaniye yere serilir.",
            "**İlk Kirişi Koyun:** Battaniyenin 1/3'üne birinci kiriş yerleştirilir ve battaniye kirişin üzerine katlanır.",
            "**İkinci Kirişi Koyun:** Katlanan kısmın bittiği yere yakın bir noktaya ikinci kiriş yerleştirilir.",
            "**Üzerini Kaplayın:** Battaniyede kalan kısım, ikinci kirişin üzerini kaplayacak şekilde üzerine doğru getirilir.",
            "**Yaralıyı Taşıyın:** Hasta/yaralı bu iki kirişin arasında oluşturulan güvenli bölgeye yatırılarak taşınır."
          ],
        ),
      ),
    ],
  ),
];







