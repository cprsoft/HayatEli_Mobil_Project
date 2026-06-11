import 'dart:convert';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../services/ai/hayat_ai_service.dart';
import '../services/audio/tts_service.dart';

class AiHelpScreen extends StatefulWidget {
  const AiHelpScreen({super.key});

  @override
  State<AiHelpScreen> createState() => _AiHelpScreenState();
}

class _AiHelpScreenState extends State<AiHelpScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final HayatAiService _aiService = HayatAiService();
  final TtsService _ttsService = TtsService();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _hasStartedChat = false;
  String _userName = "";
  List<Map<String, String>> _quickActions = [];
  bool _isLoadingActions = true;
  bool _hasInternet = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color _primaryRed = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _initConnectivity();
    _initSpeech();
    _loadUserName();
    _fetchQuickActions();
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final initialResults = await connectivity.checkConnectivity();
    _updateConnectionStatus(initialResults);

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (!mounted) return;
    setState(() {
      _hasInternet = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    });
  }

  Future<void> _loadUserName() async {
    try {
      final userBox = Hive.box('user_box');
      final profileJson = userBox.get('cached_user_profile');
      if (profileJson != null) {
        final userData = jsonDecode(profileJson);
        setState(() {
          _userName = userData['fullName'] ?? userData['name'] ?? "";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchQuickActions() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/v1/quick_actions'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _quickActions = List<Map<String, String>>.from(
            data['quick_actions'].map((e) => {"label": e["label"].toString(), "query": e["query"].toString()})
          );
          _isLoadingActions = false;
        });
      }
    } catch (e) {
      setState(() {
        _quickActions = [{"label": "🩸 Ağır Kanama", "query": "Ağır kanama var, ne yapmalıyım?"}];
        _isLoadingActions = false;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    _controller.dispose();
    _speech.stop();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  void _addAiMessage(String text) {
    setState(() => _messages.insert(0, {"role": "ai", "content": text}));
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    await _ttsService.stop();
    setState(() {
      _hasStartedChat = true;
      _messages.insert(0, {"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToTop();

    final response = await _aiService.analyzeAndRespond(text);

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = false;
      _messages.insert(0, {
        "role": "ai", 
        "content": response["response"],
        "dynamic_buttons": response["dynamic_buttons"]
      });
    });
    _scrollToTop();
    await _ttsService.speak(response["response"]);
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    await _ttsService.stop();
    setState(() => _isListening = true);

    await _speech.listen(
      localeId: 'tr_TR',
      onResult: (result) {
        _controller.text = result.recognizedWords;
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() => _isListening = false);
          _handleSendMessage(result.recognizedWords);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text("HAYAT ASİSTAN",
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18)),
        backgroundColor: _primaryRed,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_hasStartedChat)
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 22),
              tooltip: "Yeni Acil Durum (Sohbeti Temizle)",
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _hasStartedChat = false;
                  _controller.clear();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasInternet)
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "İnternet Bağlantısı Yok! AI Asistan Çevrimdışı.",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'lib/assets/images/Hayat_AI.png',
                            height: 130, // İdeal boyut (ne çok büyük ne çok küçük)
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.health_and_safety, size: 80, color: _primaryRed.withOpacity(0.5)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Merhaba ${_userName.isNotEmpty ? '$_userName' : ''}",
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            "Ben İlk Yardım Asistanınız Hayat,\nnasıl yardımcı olabilirim?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade700, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      bool isAi = msg["role"] == "ai";
                      List<String> dynamicBtns = (msg["dynamic_buttons"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                      
                      return Column(
                        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                        children: [
                          _buildChatBubble(msg["content"], isAi),
                          if (isAi)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 4.0),
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  ActionChip(
                                    avatar: const Icon(Icons.phone, color: Colors.white, size: 16),
                                    label: Text("112'Yİ ARA", style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: _primaryRed,
                                    side: const BorderSide(color: Colors.transparent),
                                    onPressed: () async {
                                      HapticFeedback.heavyImpact();
                                      try {
                                        await FlutterPhoneDirectCaller.callNumber('112');
                                      } catch (e) {
                                        print("Arama hatası: $e");
                                      }
                                    },
                                  ),
                                  if (dynamicBtns.isNotEmpty)
                                    ...dynamicBtns.map((btnQuery) => ActionChip(
                                      label: Text(btnQuery, style: GoogleFonts.inter(fontSize: 12, color: _primaryRed)),
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(color: _primaryRed),
                                      onPressed: () => _handleSendMessage(btnQuery),
                                    )).toList(),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SpinKitThreeBounce(color: _primaryRed, size: 20),
            ),
          if (!_hasStartedChat && _quickActions.isNotEmpty)
            _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickActions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(_quickActions[index]["label"]!,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryRed)),
              backgroundColor: Colors.white,
              side: BorderSide(color: _primaryRed.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => _handleSendMessage(_quickActions[index]["query"]!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : _primaryRed,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: _buildRichText(text, isAi),
      ),
    );
  }

  Widget _buildRichText(String text, bool isAi) {
    final styleNormal = GoogleFonts.inter(
      color: isAi ? Colors.black87 : Colors.white,
      fontSize: 15,
      height: 1.5,
      fontWeight: isAi ? FontWeight.w500 : FontWeight.w400,
    );
    final styleBold = GoogleFonts.inter(
      color: isAi ? _primaryRed : Colors.white,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w800,
    );

    List<TextSpan> spans = [];
    final regex = RegExp(r'(⚠️ KRİTİK UYARI|KESİNLİKLE|DİKKAT)');
    final matches = regex.allMatches(text);
    
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: styleNormal));
      }
      spans.add(TextSpan(text: match.group(0), style: styleBold));
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: styleNormal));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: IgnorePointer(
        ignoring: !_hasInternet,
        child: Opacity(
          opacity: _hasInternet ? 1.0 : 0.5,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: !_hasInternet 
                          ? "İnternet bekleniyor..." 
                          : (_isListening ? "Dinliyorum..." : "Bir mesaj yazın veya konuşun..."),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildMicButton(),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _handleSendMessage(_controller.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: _primaryRed, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    if (_isListening) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: GestureDetector(
              onTap: _toggleListening,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryRed,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _primaryRed.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 20),
              ),
            ),
          );
        },
      );
    }
    return GestureDetector(
      onTap: _toggleListening,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _speechAvailable ? Colors.white : Colors.grey.shade300,
          shape: BoxShape.circle,
          border: Border.all(color: _primaryRed.withOpacity(0.3)),
        ),
        child: Icon(Icons.mic_none, color: _speechAvailable ? _primaryRed : Colors.grey, size: 20),
      ),
    );
  }
}
