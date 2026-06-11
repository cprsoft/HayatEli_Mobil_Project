import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/first_aid_guide_data.dart';
import 'first_aid_guide_detail_screen.dart';

class FirstAidGuideScreen extends StatefulWidget {
  const FirstAidGuideScreen({super.key});

  @override
  State<FirstAidGuideScreen> createState() => _FirstAidGuideScreenState();
}

class _FirstAidGuideScreenState extends State<FirstAidGuideScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  String _searchQuery = "";
  List<FirstAidTopic> _filteredTopics = [];

  final List<Map<String, dynamic>> _popularTopics = [
    {"label": "Ağır Kanama", "id": "severe_bleeding", "color": Colors.red},
    {"label": "Kalp Krizi", "id": "heart_attack", "color": Colors.pink},
    {"label": "Heimlich", "id": "heimlich_group", "color": Colors.teal},
    {"label": "Yanıklar", "id": "heat_burns", "color": Colors.orange},
    {"label": "Zehirlenme", "id": "digestive_poisoning", "color": Colors.purple},
    {"label": "Suda Boğulma", "id": "water_drowning", "color": Colors.blue},
    {"label": "Sara Krizi", "id": "seizures", "color": Colors.deepPurple},
    {"label": "Hayvan Isırması", "id": "cat_dog_bites", "color": Colors.brown},
  ];

  // Kategori içindeki tüm topic'leri düz liste olarak döndürür
  List<FirstAidTopic> _getAllTopicsFromCategory(FirstAidCategory cat) {
    final List<FirstAidTopic> result = [];
    for (final item in cat.items) {
      if (item.isSubGroup) {
        result.addAll(item.subGroup!.topics);
      } else {
        result.add(item.topic!);
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      if (_searchQuery.isNotEmpty) {
        _filteredTopics = firstAidGuideData
            .expand((cat) => _getAllTopicsFromCategory(cat))
            .where((topic) =>
                topic.title.toLowerCase().contains(_searchQuery) ||
                topic.description.toLowerCase().contains(_searchQuery) ||
                topic.keywords.any((kw) => kw.contains(_searchQuery)))
            .toList();
      } else {
        _filteredTopics = [];
      }
    });
  }

  void _selectTopicById(String id) {
    for (var cat in firstAidGuideData) {
      // Önce alt grupları (SubGroup) kontrol et (Örn: Heimlich)
      for (var item in cat.items) {
        if (item.isSubGroup && item.subGroup!.id == id) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FirstAidSubGroupScreen(subGroup: item.subGroup!),
            ),
          );
          return;
        }
      }
      
      // Sonra standart başlıkları (Topic) kontrol et
      for (var topic in _getAllTopicsFromCategory(cat)) {
        if (topic.id == id) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FirstAidGuideDetailScreen(topic: topic),
            ),
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "Hayat Rehberi",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            color: Colors.redAccent,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Konu, belirti veya ilk yardım ara...",
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Popüler Etiketler
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: SizedBox(
              height: 44, // Artırıldı ki animasyon sırasında kırpılmasın
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _popularTopics.length,
                itemBuilder: (context, index) {
                  final pop = _popularTopics[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 2, bottom: 2),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Material(
                      color: (pop["color"] as MaterialColor).shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: (pop["color"] as MaterialColor).shade200, 
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        hoverColor: (pop["color"] as MaterialColor).shade100,
                        splashColor: (pop["color"] as MaterialColor).shade300.withValues(alpha: 0.5),
                        highlightColor: (pop["color"] as MaterialColor).shade200.withValues(alpha: 0.4),
                        onTap: () => _selectTopicById(pop["id"] as String),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 8.0),
                          child: Center(
                            child: Text(
                              pop["label"] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: (pop["color"] as MaterialColor).shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // İçerik Alanı
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Sonuç bulunamadı",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Farklı anahtar kelimelerle aramayı deneyin.",
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = _filteredTopics[index];
        return _buildTopicCard(topic);
      },
    );
  }

  Widget _buildCategoryGrid() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: firstAidGuideData.length,
      itemBuilder: (context, index) {
        final cat = firstAidGuideData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade100, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FirstAidCategoryTopicsScreen(category: cat),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cat.gradientColors[0].withOpacity(0.05),
                      cat.gradientColors[1].withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cat.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                cat.gradientColors[1].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child:
                          Icon(cat.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.description,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: cat.gradientColors[1],
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopicCard(FirstAidTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: topic.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(topic.icon, color: Colors.white, size: 24),
        ),
        title: Text(
          topic.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          topic.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FirstAidGuideDetailScreen(topic: topic),
            ),
          );
        },
      ),
    );
  }
}

class FirstAidCategoryTopicsScreen extends StatelessWidget {
  final FirstAidCategory category;

  const FirstAidCategoryTopicsScreen(
      {super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          category.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.items.length,
        itemBuilder: (context, index) {
          final item = category.items[index];

          // SubGroup kartı (Heimlich gibi)
          if (item.isSubGroup) {
            final subGroup = item.subGroup!;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: subGroup.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(subGroup.icon,
                      color: Colors.white, size: 24),
                ),
                title: Text(
                  subGroup.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  subGroup.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FirstAidSubGroupScreen(
                          subGroup: subGroup),
                    ),
                  );
                },
              ),
            );
          }

          // Normal topic kartı
          final topic = item.topic!;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: topic.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(topic.icon, color: Colors.white, size: 24),
              ),
              title: Text(
                topic.title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                topic.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FirstAidGuideDetailScreen(topic: topic),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Heimlich alt topic listesi ekranı
class FirstAidSubGroupScreen extends StatelessWidget {
  final FirstAidSubGroup subGroup;

  const FirstAidSubGroupScreen({super.key, required this.subGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          subGroup.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subGroup.topics.length,
        itemBuilder: (context, index) {
          final topic = subGroup.topics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: topic.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(topic.icon, color: Colors.white, size: 24),
              ),
              title: Text(
                topic.title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                topic.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FirstAidGuideDetailScreen(topic: topic),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}