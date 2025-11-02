import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuranScreen extends StatefulWidget {
  final String languageCode; // 'en' or 'ur'
  const QuranScreen({Key? key, required this.languageCode}) : super(key: key);

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<String> _allAyahs = [];
  List<String> _surahNames = [];
  Map<int, int> _surahStartIndex = {}; // Surah index → starting ayah index
  Map<int, int> _juzStartIndex = {}; // Juz index → starting ayah index
  Map<int, int> _ayahCountPerSurah = {};
  int _currentPage = 0;
  static const int _linesPerPage = 16;
  final PageController _pageController = PageController();
  int _selectedSurah = 0;
  int _selectedJuz = 0;

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    final jsonString = await rootBundle.loadString('assets/json/full_quran.json');
    final jsonData = json.decode(jsonString) as List<dynamic>;

    final List<String> ayahs = [];
    final List<String> surahNames = [];
    int ayahCounter = 0;

    int juzCounter = 0;
    int ayahsPerJuz = (jsonData
            .fold<int>(
                0,
                (prev, surah) =>
                    prev + (surah['ayahs'] as List).length)) ~/
        30; // integer division

    int ayahsSinceLastJuz = 0;

    for (var i = 0; i < jsonData.length; i++) {
      final surah = jsonData[i];
      surahNames.add(surah['name']); // Arabic name
      _surahStartIndex[i] = ayahCounter;

      final surahAyahs = surah['ayahs'] as List<dynamic>;
      _ayahCountPerSurah[i] = surahAyahs.length;

      // Add Bismillah at start of Surah (except Al-Fatihah)
      if (i != 0) {
        ayahs.add('بسم الله الرحمن الرحيم');
        ayahCounter++;
      }

      for (var ayah in surahAyahs) {
        ayahs.add(ayah['text']);
        ayahCounter++;
        ayahsSinceLastJuz++;

        if (juzCounter < 30 && ayahsSinceLastJuz >= ayahsPerJuz) {
          _juzStartIndex[juzCounter] = ayahCounter - 1;
          juzCounter++;
          ayahsSinceLastJuz = 0;
        }
      }

      // blank line between surahs
      ayahs.add('');
      ayahCounter++;
    }

    _juzStartIndex[29] = ayahCounter - 1;

    setState(() {
      _allAyahs = ayahs;
      _surahNames = surahNames;
    });
  }

  void _jumpToSurah(int surahIndex) {
    if (_surahStartIndex.containsKey(surahIndex)) {
      final startAyah = _surahStartIndex[surahIndex]!;
      final pageIndex = (startAyah / _linesPerPage).floor();
      _pageController.jumpToPage(pageIndex);
      setState(() {
        _currentPage = pageIndex;
        _selectedSurah = surahIndex;
      });
    }
  }

  void _jumpToJuz(int juzIndex) {
    if (_juzStartIndex.containsKey(juzIndex)) {
      final startAyah = _juzStartIndex[juzIndex]!;
      final pageIndex = (startAyah / _linesPerPage).floor();
      _pageController.jumpToPage(pageIndex);
      setState(() {
        _currentPage = pageIndex;
        _selectedJuz = juzIndex;
      });
    }
  }

int _getCurrentSurah(int pageIndex) {
  if (_surahStartIndex.isEmpty) return 0; // safety check
  final ayahIndex = pageIndex * _linesPerPage;

  // Get keys sorted descending
  final surahIndices = _surahStartIndex.keys.toList()..sort((a, b) => b.compareTo(a));

  for (var i in surahIndices) {
    if (_surahStartIndex[i]! <= ayahIndex) return i;
  }
  return 0;
}


  @override
  Widget build(BuildContext context) {
    final totalPages = (_allAyahs.length / _linesPerPage).ceil();
    final currentSurahIndex = _getCurrentSurah(_currentPage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('قرآن'),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
      ),
      body: _allAyahs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                // Surah & Juz selectors
                Container(
                  color: Colors.green.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedSurah,
                          items: List.generate(_surahNames.length, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(
                                _surahNames[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'NotoNastaliqUrdu',
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) _jumpToSurah(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedJuz,
                          items: List.generate(30, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(
                                'جزء ${index + 1}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'NotoNastaliqUrdu',
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) _jumpToJuz(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Display Surah name dynamically
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _surahNames[currentSurahIndex],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoNastaliqUrdu',
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalPages,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, pageIndex) {
                      final start = pageIndex * _linesPerPage;
                      final end = (pageIndex + 1) * _linesPerPage;
                      final pageAyahs =
                          _allAyahs.sublist(start, end > _allAyahs.length ? _allAyahs.length : end);

                      return Container(
                        color: const Color(0xFFEFF7EF),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pageAyahs.length,
                          itemBuilder: (context, index) {
                            final ayah = pageAyahs[index];
                            if (ayah.trim().isEmpty) return const SizedBox(height: 12);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                ayah,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'NotoNastaliqUrdu',
                                  fontSize: 22,
                                  height: 1.5,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1B5E20),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _currentPage > 0
                  ? () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  : null,
            ),
            Text(
              'صفحہ ${_currentPage + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
