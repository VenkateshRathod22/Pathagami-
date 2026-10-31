import 'package:flutter/material.dart';
import 'package:tripried/view/home_page/presentations/screen/home_screen.dart';
import 'package:tripried/view/bookings/presentations/screen/bookings_screen.dart';
import 'package:tripried/view/offers/presentations/screen/offers_splash_screen.dart';
import 'package:tripried/view/getaways/presentations/screen/getaways_screen.dart';
import 'package:tripried/view/help/presentations/screen/help_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),          // 0 - Home
    const BookingsScreen(),      // 1 - Bookings
    const OffersSplashScreen(),  // 2 - Offers
    const GetawaysScreen(),      // 3 - Getaways
    const HelpScreen(),          // 4 - Help
  ];

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF65A30D);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: brandColor,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.percent),
              label: 'Offers',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.wb_sunny_outlined),
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Getaways',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.help_outline),
              label: 'Help',
            ),
          ],
        ),
      ),
    );
  }
}