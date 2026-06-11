import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/first_aid_guide_data.dart';
import '../services/audio/tts_service.dart';

class FirstAidGuideDetailScreen extends ConsumerStatefulWidget {
  final FirstAidTopic topic;

  const FirstAidGuideDetailScreen({super.key, required this.topic});

  @override
  ConsumerState<FirstAidGuideDetailScreen> createState() => _FirstAidGuideDetailScreenState();
}

class _FirstAidGuideDetailScreenState extends ConsumerState<FirstAidGuideDetailScreen> with TickerProviderStateMixin {
  late TtsService _ttsService;
  bool _isPlaying = false;
  bool _isPaused = false;
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;

  final ScrollController _scrollController = ScrollController();
  bool _showFloatingControls = false;
  bool _stopRequested = false;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(ttsServiceProvider);
    _prepareSentences();



    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _stopRequested = true;
    _ttsService.stop();

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 240) {
        if (!_showFloatingControls) {
          setState(() {
            _showFloatingControls = true;
          });
        }
      } else {
        if (_showFloatingControls) {
          setState(() {
            _showFloatingControls = false;
          });
        }
      }
    }
  }

  void _scrollToActiveStep() {
    if (!_scrollController.hasClients) return;
    if (_sentences.isEmpty || _currentSentenceIndex >= _sentences.length) return;
    double offset = 0;
    final currentSentence = _sentences[_currentSentenceIndex];
    if (currentSentence.contains("adım:")) {
      int stepIndex = 0;
      for (int i = 0; i < widget.topic.steps.length; i++) {
        if (currentSentence.contains("${_getTurkishOrdinal(i)} adım:")) {
          stepIndex = i;
          break;
        }
      }
      offset = 450.0 + (stepIndex * 130.0);
    } else if (currentSentence.contains("uyarı") || currentSentence.contains("Belirtiler")) {
      offset = 180.0;
    } else if (_currentSentenceIndex == 1) {
      offset = 80.0;
    }
    double maxScroll = _scrollController.position.maxScrollExtent;
    if (offset > maxScroll) offset = maxScroll;
    if (offset < 0) offset = 0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  String _getTurkishOrdinal(int index) {
    final ordinals = [
      "Birinci",
      "İkinci",
      "Üçüncü",
      "Dördüncü",
      "Beşinci",
      "Altıncı",
      "Yedinci",
      "Sekizinci",
      "Dokuzuncu",
      "Onuncu",
      "On Birinci",
      "On İkinci",
      "On Üçüncü",
      "On Dördüncü",
      "On Beşinci",
      "On Altıncı",
      "On Yedinci",
      "On Sekizinci",
      "On Dokuzuncu",
      "Yirminci"
    ];
    if (index >= 0 && index < ordinals.length) {
      return ordinals[index];
    }
    return "${index + 1}.";
  }

  void _prepareSentences() {
    _sentences = [
      widget.topic.title,
      widget.topic.description,
    ];
    if (widget.topic.warnings != null && widget.topic.warnings!.isNotEmpty) {
      _sentences.add("Kritik uyarılar:");
      for (var warning in widget.topic.warnings!) {
        _sentences.add(warning.replaceAll("⚠️", "").replaceAll("**", "").trim());
      }
    }
    if (widget.topic.symptoms != null && widget.topic.symptoms!.isNotEmpty) {
      _sentences.add("Belirtiler:");
      for (var symptom in widget.topic.symptoms!) {
        _sentences.add(symptom.replaceAll("**", "").trim());
      }
    }
    for (int i = 0; i < widget.topic.steps.length; i++) {
      _sentences.add("${_getTurkishOrdinal(i)} adım: ${widget.topic.steps[i].replaceAll("**", "").trim()}");
    }
  }

  Future<void> _playSpeech() async {
    if (_isPlaying) return;
    if (_sentences.isEmpty) return;

    _stopRequested = false;

    if (!_isPaused) {
      _currentSentenceIndex = 0;
    }

    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });

    while (_currentSentenceIndex < _sentences.length) {
      if (_stopRequested) break;

      if (mounted) {
        setState(() {});
      }
      _scrollToActiveStep();

      await _ttsService.speak(_sentences[_currentSentenceIndex]);

      if (_stopRequested) break;

      _currentSentenceIndex++;
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        if (!_stopRequested) {
          _isPaused = false;
          _currentSentenceIndex = 0;
        }
      });
      _scrollToActiveStep();
    }
  }

  Future<void> _pauseSpeech() async {
    _stopRequested = true;
    await _ttsService.pause();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    }
  }

  Future<void> _resetSpeech() async {
    _stopRequested = true;
    await _ttsService.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentSentenceIndex = 0;
      });
      _scrollToActiveStep();
    }
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildFormattedText(String text, bool isActive, Color activeColor) {
    final parts = text.split("**");
    if (parts.length == 1) {
      return Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: isActive ? Colors.white : Colors.black87,
          height: 1.4,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }

    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      final isBold = i % 2 == 1;
      spans.add(
        TextSpan(
          text: parts[i],
          style: GoogleFonts.outfit(
            fontWeight: isBold 
                ? FontWeight.w900 
                : (isActive ? FontWeight.w600 : FontWeight.normal),
            color: isActive 
                ? Colors.white 
                : (isBold ? activeColor : Colors.black87),
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.topic.title,
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.topic.gradientColors[0].withValues(alpha: 0.15),
                    widget.topic.gradientColors[0].withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.topic.gradientColors[1].withValues(alpha: 0.15),
                    widget.topic.gradientColors[1].withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfographicHeader(),
                const SizedBox(height: 20),
                _buildPodcastPlayer(),
                _buildWarningsSection(),
                _buildSymptomsSection(),
                const SizedBox(height: 24),
                if (widget.topic.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Image.asset(
                        widget.topic.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 16),
                _buildStepsTimeline(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showFloatingControls ? 20 : -100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sesli Asistan",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _sentences.isEmpty || _currentSentenceIndex >= _sentences.length
                              ? "Asistan hazır"
                              : (_sentences[_currentSentenceIndex].length > 40
                                  ? "${_sentences[_currentSentenceIndex].substring(0, 37)}..."
                                  : _sentences[_currentSentenceIndex]),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_rounded),
                    color: Colors.grey.shade600,
                    iconSize: 20,
                    onPressed: _resetSpeech,
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isPlaying ? _pauseSpeech : _playSpeech,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: widget.topic.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.topic.gradientColors[1].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfographicHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.topic.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.topic.gradientColors[0].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.topic.icon,
              color: widget.topic.gradientColors[1],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastPlayer() {
    final progress = _sentences.isEmpty ? 0.0 : (_currentSentenceIndex + 1) / _sentences.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (_isPlaying)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    "Sesli Anlatım Asistanı",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                "${_currentSentenceIndex + 1} / ${_sentences.length}",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(widget.topic.gradientColors[1]),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_rounded),
                color: Colors.grey.shade600,
                iconSize: 26,
                onPressed: _resetSpeech,
              ),
              const SizedBox(width: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isPlaying ? _pauseSpeech : _playSpeech,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: widget.topic.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.topic.gradientColors[1].withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTimeline() {
    final steps = widget.topic.steps;
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final stepText = steps[index];
          final isStepActive = _isPlaying &&
              _sentences.isNotEmpty &&
              _currentSentenceIndex < _sentences.length &&
              _sentences[_currentSentenceIndex].contains("${_getTurkishOrdinal(index)} adım:");
          final isFaded = _isPlaying &&
              !isStepActive &&
              _sentences.isNotEmpty &&
              _currentSentenceIndex < _sentences.length &&
              _sentences[_currentSentenceIndex].contains("adım:");
          final stepImage = (widget.topic.stepImageUrls != null && 
                             widget.topic.stepImageUrls!.length > index)
              ? widget.topic.stepImageUrls![index]
              : null;
          final isEven = index % 2 == 0;

          final avatarWidget = AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isStepActive ? 84 : 76,
            height: isStepActive ? 84 : 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isStepActive 
                    ? widget.topic.gradientColors[1] 
                    : Colors.grey.shade300,
                width: isStepActive ? 4 : 2,
              ),
              boxShadow: isStepActive
                  ? [
                      BoxShadow(
                        color: widget.topic.gradientColors[1].withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: stepImage != null
                  ? Image.asset(
                      stepImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(index, isStepActive),
                    )
                  : _buildFallbackAvatar(index, isStepActive),
            ),
          );

          final cardWidget = Expanded(
            child: AnimatedScale(
              scale: isStepActive ? 1.03 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: isFaded ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isStepActive ? widget.topic.gradientColors[1] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isStepActive 
                          ? widget.topic.gradientColors[1] 
                          : Colors.grey.shade200,
                      width: isStepActive ? 2 : 1,
                    ),
                    boxShadow: isStepActive
                        ? [
                            BoxShadow(
                              color: widget.topic.gradientColors[1].withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: _buildFormattedText(stepText, isStepActive, widget.topic.gradientColors[1]),
                ),
              ),
            ),
          );

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: isEven
                        ? [
                            avatarWidget,
                            const SizedBox(width: 16),
                            cardWidget,
                          ]
                        : [
                            cardWidget,
                            const SizedBox(width: 16),
                            avatarWidget,
                          ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningsSection() {
    if (widget.topic.warnings == null || widget.topic.warnings!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "KRİTİK UYARILAR",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.red.shade800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.topic.warnings!.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "•",
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFormattedText(
                        warning,
                        false,
                        Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    if (widget.topic.symptoms == null || widget.topic.symptoms!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "BELİRTİLER VE TANIM",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue.shade800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.topic.symptoms!.map((symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "•",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFormattedText(
                        symptom,
                        false,
                        Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  IconData _getStepIcon(String id, int index) {
    if (id == 'general_first_aid') {
      switch (index) {
        case 0: return Icons.security_rounded;
        case 1: return Icons.phone_callback_rounded;
        case 2: return Icons.handshake_rounded;
      }
    } else if (id == 'body_systems_and_vitals') {
      switch (index) {
        case 0: return Icons.directions_run_rounded;
        case 1: return Icons.favorite_rounded;
        case 2: return Icons.psychology_rounded;
        case 3: return Icons.air_rounded;
        case 4: return Icons.water_drop_rounded;
        case 5: return Icons.restaurant_rounded;
      }
    } else if (id == 'patient_evaluation') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.face_retouching_natural_rounded;
        case 2: return Icons.hearing_rounded;
        case 3: return Icons.fingerprint_rounded;
        case 4: return Icons.forum_rounded;
        case 5: return Icons.accessibility_new_rounded;
      }
    } else if (id == 'scene_evaluation') {
      switch (index) {
        case 0: return Icons.no_crash_rounded;
        case 1: return Icons.change_history_rounded;
        case 2: return Icons.smoke_free_rounded;
        case 3: return Icons.air_rounded;
        case 4: return Icons.thermostat_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'adult_cpr') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.face_retouching_natural_rounded;
        case 2: return Icons.hearing_rounded;
        case 3: return Icons.favorite_rounded;
        case 4: return Icons.air_rounded;
      }
    } else if (id == 'child_cpr') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.hearing_rounded;
        case 2: return Icons.air_rounded;
        case 3: return Icons.favorite_rounded;
        case 4: return Icons.sync_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'infant_cpr') {
      switch (index) {
        case 0: return Icons.touch_app_rounded;
        case 1: return Icons.face_retouching_natural_rounded;
        case 2: return Icons.hearing_rounded;
        case 3: return Icons.air_rounded;
        case 4: return Icons.favorite_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'choking_adult_child') {
      switch (index) {
        case 0: return Icons.record_voice_over_rounded;
        case 1: return Icons.airline_seat_flat_rounded;
        case 2: return Icons.front_hand_rounded;
        case 3: return Icons.accessibility_new_rounded;
        case 4: return Icons.fitness_center_rounded;
        case 5: return Icons.sync_rounded;
      }
    } else if (id == 'choking_infant') {
      switch (index) {
        case 0: return Icons.child_care_rounded;
        case 1: return Icons.swap_vert_rounded;
        case 2: return Icons.front_hand_rounded;
        case 3: return Icons.sync_rounded;
        case 4: return Icons.fingerprint_rounded;
        case 5: return Icons.loop_rounded;
      }
    } else if (id == 'choking_self') {
      switch (index) {
        case 0: return Icons.front_hand_rounded;
        case 1: return Icons.handshake_rounded;
        case 2: return Icons.fitness_center_rounded;
        case 3: return Icons.chair_rounded;
        case 4: return Icons.arrow_forward_rounded;
        case 5: return Icons.sync_rounded;
      }
    } else if (id == 'oed_usage') {
      switch (index) {
        case 0: return Icons.power_settings_new_rounded;
        case 1: return Icons.person_rounded;
        case 2: return Icons.child_care_rounded;
        case 3: return Icons.monitor_heart_rounded;
        case 4: return Icons.bolt_rounded;
        case 5: return Icons.sync_rounded;
      }
    } else if (id == 'first_aid_abc') {
      switch (index) {
        case 0: return Icons.phone_in_talk_rounded;
        case 1: return Icons.favorite_rounded;
        case 2: return Icons.local_shipping_rounded;
        case 3: return Icons.local_hospital_rounded;
      }
    } else if (id == 'severe_bleeding') {
      switch (index) {
        case 0: return Icons.security_rounded;
        case 1: return Icons.front_hand_rounded;
        case 2: return Icons.arrow_upward_rounded;
        case 3: return Icons.layers_rounded;
        case 4: return Icons.healing_rounded;
        case 5: return Icons.airline_seat_flat_rounded;
      }
    } else if (id == 'burns') {
      switch (index) {
        case 0: return Icons.remove_circle_outline_rounded;
        case 1: return Icons.water_drop_rounded;
        case 2: return Icons.watch_rounded;
        case 3: return Icons.content_cut_rounded;
        case 4: return Icons.do_not_disturb_on_rounded;
        case 5: return Icons.warning_amber_rounded;
      }
    } else if (id == 'external_bleeding') {
      switch (index) {
        case 0: return Icons.back_hand_rounded;
        case 1: return Icons.front_hand_rounded;
        case 2: return Icons.water_drop_rounded;
        case 3: return Icons.healing_rounded;
        case 4: return Icons.arrow_upward_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'severe_bleeding') {
      switch (index) {
        case 0: return Icons.front_hand_rounded;
        case 1: return Icons.fingerprint_rounded;
        case 2: return Icons.link_rounded;
        case 3: return Icons.lock_clock_rounded;
        case 4: return Icons.ac_unit_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'internal_bleeding') {
      switch (index) {
        case 0: return Icons.search_rounded;
        case 1: return Icons.phone_in_talk_rounded;
        case 2: return Icons.airline_seat_flat_rounded;
        case 3: return Icons.thermostat_rounded;
        case 4: return Icons.forum_rounded;
        case 5: return Icons.monitor_heart_rounded;
      }
    } else if (id == 'special_area_bleeding') {
      switch (index) {
        case 0: return Icons.face_rounded;
        case 1: return Icons.front_hand_rounded;
        case 2: return Icons.airline_seat_recline_extra_rounded;
        case 3: return Icons.remove_red_eye_rounded;
        case 4: return Icons.water_drop_rounded;
        case 5: return Icons.medical_services_rounded;
      }
    } else if (id == 'general_wounds') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.search_rounded;
        case 2: return Icons.front_hand_rounded;
        case 3: return Icons.healing_rounded;
        case 4: return Icons.local_hospital_rounded;
        case 5: return Icons.vaccines_rounded;
      }
    } else if (id == 'serious_wounds') {
      switch (index) {
        case 0: return Icons.do_not_touch_rounded;
        case 1: return Icons.front_hand_rounded;
        case 2: return Icons.block_rounded;
        case 3: return Icons.water_drop_rounded;
        case 4: return Icons.healing_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'chest_wounds') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.monitor_heart_rounded;
        case 2: return Icons.layers_rounded;
        case 3: return Icons.air_rounded;
        case 4: return Icons.airline_seat_recline_extra_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'abdominal_wounds') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.monitor_heart_rounded;
        case 2: return Icons.water_drop_rounded;
        case 3: return Icons.airline_seat_flat_rounded;
        case 4: return Icons.visibility_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'skull_spine_injuries') {
      switch (index) {
        case 0: return Icons.waving_hand_rounded;
        case 1: return Icons.monitor_heart_rounded;
        case 2: return Icons.phone_in_talk_rounded;
        case 3: return Icons.do_not_touch_rounded;
        case 4: return Icons.straighten_rounded;
        case 5: return Icons.bookmark_rounded;
      }
    } else if (id == 'heat_burns') {
      switch (index) {
        case 0: return Icons.local_fire_department_rounded;
        case 1: return Icons.monitor_heart_rounded;
        case 2: return Icons.checkroom_rounded;
        case 3: return Icons.water_drop_rounded;
        case 4: return Icons.layers_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'chemical_burns') {
      switch (index) {
        case 0: return Icons.block_rounded;
        case 1: return Icons.water_drop_rounded;
        case 2: return Icons.checkroom_rounded;
        case 3: return Icons.layers_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'electric_burns') {
      switch (index) {
        case 0: return Icons.security_rounded;
        case 1: return Icons.power_off_rounded;
        case 2: return Icons.monitor_heart_rounded;
        case 3: return Icons.water_drop_rounded;
        case 4: return Icons.do_not_touch_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'heat_stroke') {
      switch (index) {
        case 0: return Icons.wb_sunny_rounded;
        case 1: return Icons.checkroom_rounded;
        case 2: return Icons.airline_seat_flat_rounded;
        case 3: return Icons.local_drink_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'frostbite') {
      switch (index) {
        case 0: return Icons.thermostat_rounded;
        case 1: return Icons.airline_seat_flat_rounded;
        case 2: return Icons.checkroom_rounded;
        case 3: return Icons.local_cafe_rounded;
        case 4: return Icons.layers_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'fractures') {
      switch (index) {
        case 0: return Icons.warning_amber_rounded;
        case 1: return Icons.watch_rounded;
        case 2: return Icons.healing_rounded;
        case 3: return Icons.straighten_rounded;
        case 4: return Icons.monitor_heart_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'sprains') {
      switch (index) {
        case 0: return Icons.medical_information_rounded;
        case 1: return Icons.arrow_upward_rounded;
        case 2: return Icons.do_not_touch_rounded;
        case 3: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'dislocations') {
      switch (index) {
        case 0: return Icons.straighten_rounded;
        case 1: return Icons.do_not_touch_rounded;
        case 2: return Icons.restaurant_rounded;
        case 3: return Icons.monitor_heart_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'immobilization') {
      switch (index) {
        case 0: return Icons.accessibility_new_rounded;
        case 1: return Icons.accessibility_rounded;
        case 2: return Icons.front_hand_rounded;
        case 3: return Icons.airline_seat_legroom_extra_rounded;
        case 4: return Icons.airline_seat_flat_rounded;
        case 5: return Icons.directions_walk_rounded;
      }
    } else if (id == 'unconsciousness') {
      switch (index) {
        case 0: return Icons.airline_seat_recline_normal_rounded;
        case 1: return Icons.airline_seat_flat_rounded;
        case 2: return Icons.monitor_heart_rounded;
        case 3: return Icons.transfer_within_a_station_rounded;
        case 4: return Icons.front_hand_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'seizures') {
      switch (index) {
        case 0: return Icons.thermostat_rounded;
        case 1: return Icons.security_rounded;
        case 2: return Icons.do_not_touch_rounded;
        case 3: return Icons.layers_rounded;
        case 4: return Icons.checkroom_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'low_blood_sugar') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.local_drink_rounded;
        case 2: return Icons.schedule_rounded;
        case 3: return Icons.airline_seat_flat_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'heart_spasm') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.airline_seat_recline_normal_rounded;
        case 2: return Icons.airline_seat_recline_extra_rounded;
        case 3: return Icons.medication_rounded;
        case 4: return Icons.phone_in_talk_rounded;
        case 5: return Icons.remove_red_eye_rounded;
      }
    } else if (id == 'heart_attack') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.airline_seat_recline_normal_rounded;
        case 2: return Icons.airline_seat_recline_extra_rounded;
        case 3: return Icons.checkroom_rounded;
        case 4: return Icons.medication_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'digestive_poisoning') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.local_drink_rounded;
        case 2: return Icons.monitor_heart_rounded;
        case 3: return Icons.remove_red_eye_rounded;
        case 4: return Icons.airline_seat_flat_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'respiratory_poisoning') {
      switch (index) {
        case 0: return Icons.air_rounded;
        case 1: return Icons.security_rounded;
        case 2: return Icons.monitor_heart_rounded;
        case 3: return Icons.airline_seat_recline_extra_rounded;
        case 4: return Icons.airline_seat_flat_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'skin_poisoning') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.front_hand_rounded;
        case 2: return Icons.checkroom_rounded;
        case 3: return Icons.water_drop_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'cat_dog_bites') {
      switch (index) {
        case 0: return Icons.monitor_heart_rounded;
        case 1: return Icons.water_drop_rounded;
        case 2: return Icons.layers_rounded;
        case 3: return Icons.healing_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'bee_stings') {
      switch (index) {
        case 0: return Icons.water_drop_rounded;
        case 1: return Icons.colorize_rounded;
        case 2: return Icons.ac_unit_rounded;
        case 3: return Icons.ac_unit_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'scorpion_stings') {
      switch (index) {
        case 0: return Icons.do_not_touch_rounded;
        case 1: return Icons.airline_seat_flat_rounded;
        case 2: return Icons.ac_unit_rounded;
        case 3: return Icons.healing_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'snake_bites') {
      switch (index) {
        case 0: return Icons.airline_seat_recline_extra_rounded;
        case 1: return Icons.water_drop_rounded;
        case 2: return Icons.checkroom_rounded;
        case 3: return Icons.healing_rounded;
        case 4: return Icons.ac_unit_rounded;
        case 5: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'marine_animal_stings') {
      switch (index) {
        case 0: return Icons.do_not_touch_rounded;
        case 1: return Icons.colorize_rounded;
        case 2: return Icons.local_fire_department_rounded;
        case 3: return Icons.local_hospital_rounded;
      }
    } else if (id == 'eye_foreign_body') {
      switch (index) {
        case 0: return Icons.wb_sunny_rounded;
        case 1: return Icons.cleaning_services_rounded;
        case 2: return Icons.do_not_touch_rounded;
        case 3: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'ear_foreign_body') {
      switch (index) {
        case 0: return Icons.do_not_touch_rounded;
        case 1: return Icons.water_drop_rounded;
        case 2: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'nose_foreign_body') {
      switch (index) {
        case 0: return Icons.air_rounded;
        case 1: return Icons.do_not_touch_rounded;
        case 2: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'general_drowning') {
      switch (index) {
        case 0: return Icons.cleaning_services_rounded;
        case 1: return Icons.psychology_rounded;
        case 2: return Icons.monitor_heart_rounded;
        case 3: return Icons.airline_seat_flat_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'water_drowning') {
      switch (index) {
        case 0: return Icons.air_rounded;
        case 1: return Icons.pool_rounded;
        case 2: return Icons.accessibility_new_rounded;
        case 3: return Icons.monitor_heart_rounded;
        case 4: return Icons.phone_in_talk_rounded;
      }
    } else if (id == 'transport_general') {
      switch (index) {
        case 0: return Icons.transfer_within_a_station_rounded;
        case 1: return Icons.airline_seat_legroom_extra_rounded;
        case 2: return Icons.directions_walk_rounded;
        case 3: return Icons.record_voice_over_rounded;
      }
    } else if (id == 'rentek_maneuver') {
      switch (index) {
        case 0: return Icons.local_fire_department_rounded;
        case 1: return Icons.record_voice_over_rounded;
        case 2: return Icons.airline_seat_legroom_extra_rounded;
        case 3: return Icons.accessibility_new_rounded;
        case 4: return Icons.airline_seat_recline_extra_rounded;
        case 5: return Icons.airline_seat_flat_rounded;
      }
    } else if (id == 'short_distance_transport') {
      switch (index) {
        case 0: return Icons.accessibility_rounded;
        case 1: return Icons.pregnant_woman_rounded;
        case 2: return Icons.local_fire_department_rounded;
        case 3: return Icons.volunteer_activism_rounded;
        case 4: return Icons.airline_seat_recline_normal_rounded;
      }
    } else if (id == 'stretcher_placement') {
      switch (index) {
        case 0: return Icons.restaurant_rounded;
        case 1: return Icons.transfer_within_a_station_rounded;
        case 2: return Icons.accessibility_new_rounded;
      }
    } else if (id == 'stretcher_transport') {
      switch (index) {
        case 0: return Icons.airline_seat_flat_rounded;
        case 1: return Icons.fitness_center_rounded;
        case 2: return Icons.directions_walk_rounded;
        case 3: return Icons.groups_rounded;
        case 4: return Icons.stairs_rounded;
      }
    } else if (id == 'stretcher_making') {
      switch (index) {
        case 0: return Icons.layers_rounded;
        case 1: return Icons.layers_rounded;
        case 2: return Icons.straighten_rounded;
        case 3: return Icons.straighten_rounded;
        case 4: return Icons.layers_clear_rounded;
        case 5: return Icons.airline_seat_flat_rounded;
      }
    }
    return Icons.emergency_share_outlined;
  }

  Widget _buildFallbackAvatar(int index, bool isActive) {
    final isChain = widget.topic.id == 'first_aid_abc';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.topic.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStepIcon(widget.topic.id, index),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              isChain ? "HALKA ${index + 1}" : "${index + 1}",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
