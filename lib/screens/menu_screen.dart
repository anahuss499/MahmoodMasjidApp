import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class MenuScreen extends StatelessWidget {
  final ZoomDrawerController zoomDrawerController;
  final String languageCode;

  const MenuScreen({
    Key? key,
    required this.zoomDrawerController,
    required this.languageCode,
  }) : super(key: key);

  Widget _menuItem(IconData icon, String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: Colors.white12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = languageCode == 'ur';

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App title
              Center(
                child: Text(
                  isUrdu ? 'محمود مسجد' : 'Mahmood Masjid',
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Menu items
              _menuItem(Icons.info_outline, isUrdu ? 'ہمارے بارے میں' : 'About Us', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.phone, isUrdu ? 'رابطہ کریں' : 'Contact Us', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.menu_book_rounded, isUrdu ? 'قرآن' : 'Qur’an', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.fingerprint, isUrdu ? 'تسبیح' : 'Tasbeeh', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.notifications_active, isUrdu ? 'اطلاعات' : 'Notifications', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.share, isUrdu ? 'ایپ شیئر کریں' : 'Share App', () {
                zoomDrawerController.toggle!();
              }),
              _menuItem(Icons.rate_review, isUrdu ? 'ریویو دیں' : 'Submit Review', () {
                zoomDrawerController.toggle!();
              }),

              const Spacer(),

              // Footer
              const Divider(color: Colors.white24),
              Center(
                child: Text(
                  isUrdu
                      ? '© ${DateTime.now().year} محمود مسجد - گجرات'
                      : '© ${DateTime.now().year} Mahmood Masjid - Gujrat',
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

