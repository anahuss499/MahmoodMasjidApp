import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:hijri/hijri_calendar.dart';

class HomeScreen extends StatefulWidget {
  final String languageCode; // 'en' or 'ur'
  final VoidCallback onMenuPressed;

  const HomeScreen({
    Key? key,
    required this.languageCode,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late PrayerTimes _prayerTimes;
  late HijriCalendar _hijriDate;
  late DateTime _now;
  late Timer _timer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  int _selectedIndex = 0;
  static const Duration _pstOffset = Duration(hours: 5);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _initializePrayerTimes();
    _startClock();
    _animController.forward();
  }

  void _initializePrayerTimes() {
    // Coordinates for Gujrat, Pakistan
    final coordinates = Coordinates(32.5731, 74.0789);

    // <<< CORRECT API: use CalculationMethodParameters to get CalculationParameters >>>
    final params = CalculationMethodParameters.ummAlQura();

    // Current local date
    final now = DateTime.now();

    // Create PrayerTimes using named parameters (this is what adhan_dart expects)
    _prayerTimes = PrayerTimes(
      date: now,
      coordinates: coordinates,
      calculationParameters: params,
      // precision: true, // uncomment if you want second precision
    );

    // Hijri date
    _hijriDate = HijriCalendar.now();

    // Current PST time
    _now = now.toUtc().add(_pstOffset);
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now().toUtc().add(_pstOffset);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  String _formatToPst12(DateTime dt) {
    final pst = dt.toUtc().add(_pstOffset);
    final hour = pst.hour % 12 == 0 ? 12 : pst.hour % 12;
    final minute = pst.minute.toString().padLeft(2, '0');
    final ampm = pst.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _liveClock() {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = widget.languageCode == 'ur';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    // Translations
    final t = {
      'fajr': isUrdu ? 'فجر' : 'Fajr',
      'sunrise': isUrdu ? 'طلوع آفتاب' : 'Sunrise',
      'dhuhr': isUrdu ? 'ظہر' : 'Dhuhr',
      'asr': isUrdu ? 'عصر' : 'Asr',
      'maghrib': isUrdu ? 'مغرب' : 'Maghrib',
      'isha': isUrdu ? 'عشاء' : 'Isha',
      'masjid': isUrdu ? 'محمود مسجد' : 'Mahmood Masjid',
      'timeZone': isUrdu ? 'پاکستانی وقت (PST)' : 'Pakistan Standard Time (PST)',
      'gregorian': isUrdu ? 'عیسوی تاریخ' : 'Gregorian Date',
      'hijri': isUrdu ? 'ہجری تاریخ' : 'Hijri Date',
      'copyright': isUrdu
          ? '© ${DateTime.now().year} محمود مسجد - گجرات'
          : '© ${DateTime.now().year} Mahmood Masjid - Gujrat',
      'settings': isUrdu ? 'سیٹنگز' : 'Settings',
      'calendar': isUrdu ? 'کیلنڈر' : 'Calendar',
      'notifications': isUrdu ? 'اطلاعات' : 'Notifications',
    };

    DateTime safe(DateTime? dt) => dt ?? DateTime.now().toUtc();

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'نماز کے اوقات' : 'Prayer Times'),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: widget.onMenuPressed,
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    t['masjid']!,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize: isSmall ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _liveClock(),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(
                      fontSize: isSmall ? 34 : 44,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t['timeZone']!,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${t['gregorian']!}: ${_now.day}-${_now.month}-${_now.year}',
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${t['hijri']!}: ${_hijriDate.toFormat("dd MMMM yyyy")}',
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                  _prayerCard(t['fajr']!, _formatToPst12(safe(_prayerTimes.fajr)), isSmall, isUrdu),
                  _prayerCard(t['sunrise']!, _formatToPst12(safe(_prayerTimes.sunrise)), isSmall, isUrdu),
                  _prayerCard(t['dhuhr']!, _formatToPst12(safe(_prayerTimes.dhuhr)), isSmall, isUrdu),
                  _prayerCard(t['asr']!, _formatToPst12(safe(_prayerTimes.asr)), isSmall, isUrdu),
                  _prayerCard(t['maghrib']!, _formatToPst12(safe(_prayerTimes.maghrib)), isSmall, isUrdu),
                  _prayerCard(t['isha']!, _formatToPst12(safe(_prayerTimes.isha)), isSmall, isUrdu),
                  const SizedBox(height: 28),
                  Text(
                    t['copyright']!,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.white70,
  backgroundColor: const Color(0xFF1B5E20),
  onTap: _onBottomNavTap,
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: widget.languageCode == 'ur' ? 'سیٹنگز' : 'Settings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: widget.languageCode == 'ur' ? 'کیلنڈر' : 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_active),
      label: widget.languageCode == 'ur' ? 'اطلاعات' : 'Notifications',
    ),
  ],
),

    );
  }

  Widget _prayerCard(String name, String timeText, bool isSmall, bool isUrdu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: const Icon(Icons.access_time, color: Colors.green),
          title: Text(
            name,
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.w600,
              fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
            ),
          ),
          trailing: Text(
            timeText,
            style: TextStyle(
              fontSize: isSmall ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
              fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
            ),
          ),
        ),
      ),
    );
  }
}

