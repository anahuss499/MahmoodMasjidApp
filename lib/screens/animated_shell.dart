import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'home_screen.dart';

class AnimatedShell extends StatefulWidget {
  final String languageCode;

  const AnimatedShell({Key? key, required this.languageCode}) : super(key: key);

  @override
  State<AnimatedShell> createState() => _AnimatedShellState();
}

class _AnimatedShellState extends State<AnimatedShell> {
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      borderRadius: 30.0,
      showShadow: true,
      angle: 0.0, // ✅ Only zooms out (no tilt)
      slideWidth: MediaQuery.of(context).size.width * 0.75,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.easeInBack,
      mainScreenTapClose: true,
      style: DrawerStyle.defaultStyle,
      mainScreen: HomeScreen(
        languageCode: widget.languageCode,
        onMenuPressed: () {
          _drawerController.toggle!();
        },
      ),
      menuScreen: _SideMenu(languageCode: widget.languageCode),
    );
  }
}

class _SideMenu extends StatelessWidget {
  final String languageCode;

  const _SideMenu({Key? key, required this.languageCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUrdu = languageCode == 'ur';

    final menuItems = [
      {'iconPath': 'assets/icons/about.png', 'text': isUrdu ? 'ہمارے بارے میں' : 'About Us'},
      {'iconPath': 'assets/icons/contact.png', 'text': isUrdu ? 'رابطہ کریں' : 'Contact Us'},
      {'iconPath': 'assets/icons/quran.png', 'text': isUrdu ? 'قرآن' : 'Quran'},
      {'iconPath': 'assets/icons/tasbeeh.png', 'text': isUrdu ? 'تسبیح' : 'Tasbeeh'},
      {'iconPath': 'assets/icons/notifications.png', 'text': isUrdu ? 'اطلاعات' : 'Notifications'},
      {'iconPath': 'assets/icons/share.png', 'text': isUrdu ? 'ایپ شیئر کریں' : 'Share App'},
      {'iconPath': 'assets/icons/review.png', 'text': isUrdu ? 'جائزہ دیں' : 'Submit Review'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent, // fully transparent
              borderRadius: BorderRadius.circular(30), // modern smooth corners
              border: Border.all(
                color: const Color(0xFF1B5E20), // darker modern green border
                width: 1.8,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? 'محمود مسجد' : 'Mahmood Masjid',
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return _BouncyMenuItem(
                        iconPath: item['iconPath']!,
                        text: item['text']!,
                        isUrdu: isUrdu,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BouncyMenuItem extends StatefulWidget {
  final String iconPath;
  final String text;
  final bool isUrdu;

  const _BouncyMenuItem({
    required this.iconPath,
    required this.text,
    required this.isUrdu,
  });

  @override
  State<_BouncyMenuItem> createState() => _BouncyMenuItemState();
}

class _BouncyMenuItemState extends State<_BouncyMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context) async {
    await _controller.forward();
    await _controller.reverse();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.text} ${widget.isUrdu ? 'جلد آرہا ہے!' : 'coming soon!'}'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    ZoomDrawer.of(context)?.close();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Image.asset(
            widget.iconPath,
            width: 32,
            height: 32,
            color: const Color.fromARGB(179, 10, 4, 4),
          ),
          title: Text(
            widget.text,
            textDirection: widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              color: const Color.fromARGB(179, 63, 146, 56),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: widget.isUrdu ? 'NotoNastaliqUrdu' : null,
            ),
          ),
          onTap: () => _onTap(context),
        ),
      ),
    );
  }
}
