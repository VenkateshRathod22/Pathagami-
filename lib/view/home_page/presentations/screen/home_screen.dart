import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripried/view/account/presentations/screen/account_screen.dart';
import 'package:tripried/view/bookings/booking_room.dart';
import 'package:tripried/view/bike/presentations/screen/bike_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_booking_screen.dart';
import 'package:tripried/view/bus/presentations/screen/bus_screen.dart';
import 'package:tripried/view/car/presentations/screen/car_screen.dart';
import 'package:tripried/view/hotel/presentations/screen/hotel_screen.dart';
import 'package:tripried/view/offers/presentations/screen/offers_splash_screen.dart';
import 'package:tripried/view/parcel/presentations/screen/parcel_screen.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import 'package:tripried/view/account/sub_features/account_settings/presentations/widgets/logout_dialog.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/services/wallet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeService = 'Bus';

  // Bus Search Form State
  String _fromCity = 'Delhi';
  String _toCity = 'Lucknow';
  DateTime _journeyDate = DateTime.now();
  bool _isWomenBooking = false;

  void _onWalletChanged() {
    if (mounted) setState(() {});
  }

  // Top Hero Slider / Carousel State
  final PageController _heroSliderController = PageController();
  int _currentHeroSlide = 0;
  Timer? _heroSliderTimer;

  // Offers Carousel State
  final PageController _offersPageController = PageController(viewportFraction: 0.88);
  int _currentOfferPage = 0;
  Timer? _offersTimer;
  String _selectedOfferCategory = 'All';

  final List<String> _offerCategories = ['All', 'Bus', 'Bike', 'Car', 'Parcel', 'Hotel'];

  // Hotels Carousel State
  final PageController _hotelsPageController = PageController(viewportFraction: 0.86);
  int _currentHotelPage = 0;
  Timer? _hotelsTimer;

  // Verified HD Hotel Deals with real prices & early check-in
  final List<Map<String, dynamic>> _hotelDealsList = [
    {
      'name': 'Grand Comfort Inn',
      'location': 'Central Station, Delhi',
      'price': '₹399',
      'originalPrice': '₹1,299',
      'discount': '69% OFF',
      'rating': '4.5',
      'reviews': '1.2k',
      'tag': 'BEST VALUE',
      'tagColor': const Color(0xFF16A34A),
      'amenities': 'Free WiFi • AC • Breakfast',
      'imageUrl': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'The Royal Palm Suite',
      'location': 'MG Road, Bengaluru',
      'price': '₹649',
      'originalPrice': '₹1,599',
      'discount': '59% OFF',
      'rating': '4.7',
      'reviews': '850',
      'tag': 'EARLY CHECK-IN',
      'tagColor': const Color(0xFF2563EB),
      'amenities': 'Early Check-in • Pool • WiFi',
      'imageUrl': 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Heritage Palace & Spa',
      'location': 'Hawa Mahal, Jaipur',
      'price': '₹899',
      'originalPrice': '₹2,199',
      'discount': '59% OFF',
      'rating': '4.8',
      'reviews': '2.1k',
      'tag': 'PREMIUM STAY',
      'tagColor': const Color(0xFF9333EA),
      'amenities': 'Heritage View • Spa • Restaurant',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Urban Boutique Stay',
      'location': 'Cyber City, Gurugram',
      'price': '₹799',
      'originalPrice': '₹1,799',
      'discount': '55% OFF',
      'rating': '4.6',
      'reviews': '940',
      'tag': 'FREE CANCELLATION',
      'tagColor': const Color(0xFF0D9488),
      'amenities': 'Free Cancellation • AC • Work Desk',
      'imageUrl': 'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?auto=format&fit=crop&w=800&q=80',
    },
    {
      'name': 'Lakeview Resort & Villa',
      'location': 'Fateh Sagar, Udaipur',
      'price': '₹1,199',
      'originalPrice': '₹2,899',
      'discount': '58% OFF',
      'rating': '4.9',
      'reviews': '3.4k',
      'tag': 'LUXURY GETAWAY',
      'tagColor': const Color(0xFFDC2626),
      'amenities': 'Lake View • Pool • Buffet',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80',
    },
  ];

  // Top Hero Slides Data
  final List<Map<String, dynamic>> _heroSlides = [
    {
      'title': 'Taking India Home Sale!',
      'subtitle': 'Save up to ₹300 on bus tickets using code SPINGO300',
      'tag': 'FESTIVAL SPECIAL',
      'tagColor': const Color(0xFF65A30D),
      'gradient': [const Color(0xFF0F172A), const Color(0xFF14532D)],
      'imageUrl': 'assets/images/spingo_bus_banner.jpg',
    },
    {
      'title': 'ZERO Convenience Fee*',
      'subtitle': 'Book with zero hidden charges & enjoy live GPS tracking',
      'tag': 'TRUSTED BY 23L+ USERS',
      'tagColor': const Color(0xFF0F766E),
      'gradient': [const Color(0xFF0F2B66), const Color(0xFF1E40AF)],
      'imageUrl': 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80',
    },
    {
      'title': 'Hotels from ₹399 with Early Check-in',
      'subtitle': 'Clean, verified stays across 150+ Indian cities',
      'tag': 'SAVE UP TO 70%',
      'tagColor': const Color(0xFF7E22CE),
      'gradient': [const Color(0xFF581C87), const Color(0xFF9333EA)],
      'imageUrl': 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=600&q=80',
    },
  ];

  final List<Map<String, dynamic>> _offersList = [
    {
      'category': 'Bus',
      'title': 'Save up to Rs 300 on bus tickets',
      'validity': 'Valid till: 25 Oct',
      'code': 'FESTIVE300',
      'bgColor': const Color(0xFFFEF3C7),
      'saleTag': 'TAKING\nINDIA HOME\nSALE',
      'saleDates': '10th OCT - 25th OCT',
      'imageUrl': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=800&q=80',
    },
    {
      'category': 'Bus',
      'title': 'Save up to Rs 250 on first booking',
      'validity': 'Valid till: 31 Oct',
      'code': 'FIRST',
      'bgColor': const Color(0xFFFFE4E6),
      'saleTag': 'SPECIAL\nNEW USER\nBONUS',
      'saleDates': 'VALID ALL MONTH',
      'imageUrl': 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=800&q=80',
    },
    {
      'category': 'Bike',
      'title': 'Flat 30% off on first 3 Bike Taxi rides',
      'validity': 'Valid till: 15 Nov',
      'code': 'BIKE30',
      'bgColor': const Color(0xFFFEF3C7),
      'saleTag': 'FAST & EASY\nBIKE\nRIDE',
      'saleDates': 'DAILY COMMUTE',
      'imageUrl': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
    },
    {
      'category': 'Hotel',
      'title': 'Save up to 50% on luxury stays',
      'validity': 'Valid till: 30 Nov',
      'code': 'HOTEL50',
      'bgColor': const Color(0xFFE0F2FE),
      'saleTag': 'MEGA\nHOLIDAY\nSAVER',
      'saleDates': 'LIMITED TIME',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    WalletService.instance.addListener(_onWalletChanged);
    WalletService.instance.loadFromCache();
    WalletService.instance.fetchWallet();
    _startHeroAutoScroll();
    _startOffersAutoScroll();
    _startHotelsAutoScroll();
  }

  void _startHeroAutoScroll() {
    _heroSliderTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroSliderController.hasClients) {
        final nextPage = (_currentHeroSlide + 1) % _heroSlides.length;
        _heroSliderController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startOffersAutoScroll() {
    _offersTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_offersPageController.hasClients) {
        final nextPage = (_currentOfferPage + 1) % _offersList.length;
        _offersPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startHotelsAutoScroll() {
    _hotelsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_hotelsPageController.hasClients) {
        final nextPage = (_currentHotelPage + 1) % _hotelDealsList.length;
        _hotelsPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    WalletService.instance.removeListener(_onWalletChanged);
    _heroSliderTimer?.cancel();
    _heroSliderController.dispose();
    _offersTimer?.cancel();
    _offersPageController.dispose();
    _hotelsTimer?.cancel();
    _hotelsPageController.dispose();
    super.dispose();
  }

  void _swapCities() {
    setState(() {
      final temp = _fromCity;
      _fromCity = _toCity;
      _toCity = temp;
    });
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday ${date.day}-$month';
  }

  void _navigateToBookingScreen({String? destination}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusBookingScreen(
          fromCity: _fromCity,
          toCity: destination ?? _toCity,
          date: _formatDate(_journeyDate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER: redBus Logo, Wallet ₹0, My Account
              _buildTopHeader(),

              // 2. TOP HERO PROMOTIONAL SLIDER / BANNER
              _buildTopHeroSlider(),

              const SizedBox(height: 12),

              // 3. TOP SERVICE CATEGORIES: Bus, Bike, Car, Parcel, Hotel
              _buildServiceCategories(),

              const SizedBox(height: 18),

              // 4. BOOK BUS TICKETS SEARCH CARD (Calls Booking Page on search)
              _buildBookBusTicketsCard(),

              const SizedBox(height: 24),

              // 5. OFFERS SECTION (Auto-scroll Carousel + Tabs + Indicator)
              _buildOffersSection(),

              const SizedBox(height: 24),

              // 6. INTRODUCING GETAWAYS (Ooty, Mysuru, Kodaikanal, Tirupati HD Cards)
              _buildGetawaysSection(),

              const SizedBox(height: 24),

              // 7. BOOK HOTELS FROM ₹399 WITH EARLY CHECK-IN (HD Room Cards)
              _buildHotelsBanner(),

              const SizedBox(height: 24),

              // 8. BOOK CABS & BIKE RIDES FOR FESTIVALS
              _buildRidesAndCabsBanner(),

              const SizedBox(height: 24),

              // 9. COUPON CREATOR & EXCLUSIVE GIFT CARDS
              _buildCouponAndGiftSection(),

              const SizedBox(height: 24),

              // 10. RATE US SECTION
              _buildRateUsSection(),

              const SizedBox(height: 24),

              // 11. TOP DESTINATIONS FROM LUCKNOW (Delhi, Jaipur, Varanasi with HD Photos)
              _buildTopDestinationsSection(),

              const SizedBox(height: 24),

              // 12. GOVERNMENT RTC BUSES
              _buildGovernmentBusesSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION BAR
    );
  }

// ==========================================
// 1. TOP HEADER (Overflow Fixed)
// ==========================================
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // Logo
          const SpingoLogo(height: 32),

          const SizedBox(width: 12),

          // Right side buttons (Flexible so overflow na aaye)
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Wallet button
                Flexible(
                  child: InkWell(
                    onTap: () => LogoutDialog.show(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 15, color: Colors.black87),


                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WalletScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 15, color: Colors.black87),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Wallet ₹${WalletService.instance.balance.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // My Account button
                Flexible(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline, size: 15, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'My Account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. TOP HERO PROMOTIONAL SLIDER
  // ==========================================
  Widget _buildTopHeroSlider() {
    return Column(
      children: [
        SizedBox(
          height: 125,
          child: PageView.builder(
            controller: _heroSliderController,
            itemCount: _heroSlides.length,
            onPageChanged: (index) {
              setState(() => _currentHeroSlide = index);
            },
            itemBuilder: (context, index) {
              final slide = _heroSlides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Background HD Image with Overlay
                      Positioned.fill(
                        child: _buildHDImage(
                          slide['imageUrl'] as String,
                          fit: BoxFit.cover,
                          fallbackGradient: slide['gradient'] as List<Color>,
                          fallbackIcon: Icons.directions_bus,
                        ),
                      ),

                      // Gradient Overlay for readability
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.black.withValues(alpha: 0.55),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Slide Content
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: slide['tagColor'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                slide['tag'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              slide['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              slide['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Indicator Dots for Top Slider
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroSlides.length, (index) {
            final isCurrent = index == _currentHeroSlide;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF65A30D) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ==========================================
  // 3. TOP SERVICE CATEGORIES (Bus, Bike, Car, Parcel, Hotel with HD visual styling)
  // ==========================================
  Widget _buildServiceCategories() {
    final categories = [
      {
        'title': 'Bus',
        'badge': '₹300 off',
        'icon': Icons.directions_bus_rounded,
        'color': const Color(0xFF65A30D),
        'imageUrl': 'assets/images/modern_luxury_bus.jpg',
      },
      {
        'title': 'Bike',
        'badge': '30% Off',
        'icon': Icons.two_wheeler_rounded,
        'color': const Color(0xFFF59E0B),
        'imageUrl': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Car',
        'badge': 'From ₹9/km',
        'icon': Icons.directions_car_rounded,
        'color': const Color(0xFF0284C7),
        'imageUrl': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Parcel',
        'badge': 'Doorstep',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFF10B981),
        'imageUrl': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=200&q=80',
      },
      {
        'title': 'Hotel',
        'badge': 'Save 70%',
        'icon': Icons.hotel_rounded,
        'color': const Color(0xFF9333EA),
        'imageUrl': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=200&q=80',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _activeService == cat['title'];
          return GestureDetector(
            onTap: () {
              setState(() => _activeService = cat['title'] as String);
              if (cat['title'] == 'Bus') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusScreen()),
                );
              } else if (cat['title'] == 'Bike') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BikeScreen()),
                );
              } else if (cat['title'] == 'Car') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarScreen()),
                );
              } else if (cat['title'] == 'Parcel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParcelScreen()),
                );
              } else if (cat['title'] == 'Hotel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelScreen()),
                );
              }
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF65A30D) : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Discount Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cat['badge'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Visual Thumbnail / Icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildHDImage(
                        cat['imageUrl'] as String,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        fallbackIcon: cat['icon'] as IconData,
                        fallbackColor: cat['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Label
                  Text(
                    cat['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFFD83A3A) : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  // ==========================================
  // 4. BOOK BUS TICKETS SEARCH CARD (Calls Booking Page!)
  // ==========================================
  Widget _buildBookBusTicketsCard() {
    const primaryRed = Color(0xFF65A30D);
    const navyBlue = Color(0xFF0F2B66);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Book bus tickets',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Main Card with Navy Top Ribbon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Ribbon: ZERO convenience fee*
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: navyBlue,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: const Center(
                    child: Text(
                      'ZERO convenience fee*',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // From & To City Row with Swap Button
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Column(
                      children: [
                        // FROM Row
                        InkWell(
                          onTap: () => _pickCity(true),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 60, 12),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_bus_outlined, color: Colors.grey, size: 24),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('From', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _fromCity,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Divider(height: 1, indent: 54),

                        // TO Row
                        InkWell(
                          onTap: () => _pickCity(false),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 60, 14),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_bus_outlined, color: Colors.grey, size: 24),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('To', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _toCity,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Floating Swap Button (⇅)
                    Positioned(
                      right: 16,
                      child: GestureDetector(
                        onTap: _swapCities,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF475569),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.swap_vert, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                // Date of Journey Row with Today & Tomorrow Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Colors.grey, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date of Journey', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(_journeyDate),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Today Pill
                      GestureDetector(
                        onTap: () => setState(() => _journeyDate = DateTime.now()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFCCB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Tomorrow Pill
                      GestureDetector(
                        onTap: () => setState(() => _journeyDate = DateTime.now().add(const Duration(days: 1))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFCCB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tomorrow',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Booking for women toggle row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.face_3, color: Colors.pink, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking for women',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Women passengers can book reserved adjacent seats with priority safety.')),
                                );
                              },
                              child: const Text(
                                'Know more',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2563EB),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isWomenBooking,
                        activeThumbColor: const Color(0xFF475569),
                        onChanged: (val) {
                          setState(() => _isWomenBooking = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search buses Red Button -> OPENS BUS BOOKING PAGE!
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 2,
              ),
              onPressed: () => _navigateToBookingScreen(),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Search buses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  // ==========================================
  // 5. OFFERS SECTION (Auto-scroll Carousel)
  // ==========================================
  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Offers & View all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Get best deals with great offers',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OffersSplashScreen()),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Filter Category Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _offerCategories.map((cat) {
              final isSelected = _selectedOfferCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedOfferCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFE4E6) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD83A3A) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFFD83A3A) : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Automatic Scrolling Offers Carousel
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _offersPageController,
            itemCount: _offersList.length,
            onPageChanged: (index) {
              setState(() => _currentOfferPage = index);
            },
            itemBuilder: (context, index) {
              final offer = _offersList[index];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OffersSplashScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: offer['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Details on left
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                offer['category'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              offer['title'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.25,
                              ),
                            ),
                            Text(
                              offer['validity'] as String,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: offer['code'] as String));
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: const Color(0xFF1E293B),
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
                                        const SizedBox(width: 8),
                                        Text('Coupon ${offer['code']} copied!'),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_offer_outlined, size: 14, color: Color(0xFFD83A3A)),
                                    const SizedBox(width: 6),
                                    Text(
                                      offer['code'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // HD Network Image on right with rounded frame & overlay
                      Expanded(
                        flex: 2,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildHDImage(
                                offer['imageUrl'] as String,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient shadow overlay on bottom of image for badge legibility
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                            // Sale dates badge floating on image
                            Positioned(
                              bottom: 8,
                              left: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  offer['saleDates'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFDC2626),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Indicator: Red elongated capsule + grey dots
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_offersList.length, (index) {
              final isCurrent = index == _currentOfferPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 26 : 7,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFD83A3A) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildGetawaysSection() {
    final destinations = [
      {
        'name': 'Ooty',
        'imageUrl': 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=300&q=80',
        'gradient': const [Color(0xFF0D9488), Color(0xFF059669)],
        'icon': Icons.landscape,
      },
      {
        'name': 'Mysuru',
        'imageUrl': 'https://images.unsplash.com/photo-1600100397608-f010f443b749?auto=format&fit=crop&w=300&q=80',
        'gradient': const [Color(0xFFEA580C), Color(0xFFC2410C)],
        'icon': Icons.account_balance,
      },
      {
        'name': 'Kodaikanal',
        'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=300&q=80',
        'gradient': const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        'icon': Icons.water_drop,
      },
      {
        'name': 'Tirupati',
        'imageUrl': 'https://images.unsplash.com/photo-1621847468516-1ed5d0df56fe?auto=format&fit=crop&w=300&q=80',
        'gradient': const [Color(0xFFD97706), Color(0xFFB45309)],
        'icon': Icons.temple_hindu,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Text(
              'Introducing Getaways',
              style: TextStyle(color: Color(0xFFD83A3A), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hey, ready for a weekend getaway?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              'Handpicked destinations for you',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Horizontal Scrollable Cards (wider & better looking)
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: destinations.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final dest = destinations[index];
                  return GestureDetector(
                    onTap: () => _navigateToBookingScreen(destination: dest['name'] as String),
                    child: Container(
                      width: 140, // ← Ab cards wider hain
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // HD Image
                            Positioned.fill(
                              child: _buildHDImage(
                                dest['imageUrl'] as String,
                                fit: BoxFit.cover,
                                fallbackGradient: dest['gradient'] as List<Color>,
                                fallbackIcon: dest['icon'] as IconData,
                              ),
                            ),

                            // Bottom name bar
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              child: Text(
                                dest['name'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 7. BOOK HOTELS FROM ₹399 BANNER (Auto-Scrolling HD Room Slider)
  // ==========================================
  Widget _buildHotelsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF5D0FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book hotels from ₹399',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: Color(0xFFEAB308), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Early check-in • Save up to 70%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingRoom()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E22CE).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7E22CE),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF7E22CE)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Automatic Scrolling Hotel Image Slider
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _hotelsPageController,
              itemCount: _hotelDealsList.length,
              onPageChanged: (index) {
                setState(() => _currentHotelPage = index);
              },
              itemBuilder: (context, index) {
                final hotel = _hotelDealsList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingRoom()),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top HD Image with Badges & Rating
                        Expanded(
                          flex: 12,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildHDImage(
                                hotel['imageUrl'] as String,
                                fit: BoxFit.cover,
                                fallbackColor: const Color(0xFFF1F5F9),
                                fallbackIcon: Icons.hotel,
                              ),
                              // Bottom subtle gradient on image
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.55),
                                    ],
                                    stops: const [0.55, 1.0],
                                  ),
                                ),
                              ),
                              // Top-left Tag Badge (e.g. BEST VALUE, EARLY CHECK-IN)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: (hotel['tagColor'] as Color).withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    hotel['tag'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                              // Top-right Rating Badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF15803D),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, color: Colors.white, size: 11),
                                      const SizedBox(width: 3),
                                      Text(
                                        hotel['rating'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Location text floating on bottom left of image
                              Positioned(
                                bottom: 6,
                                left: 8,
                                right: 8,
                                child: Text(
                                  '📍 ${hotel['location'] as String}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Hotel Info & Prices
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            children: [
                              // Hotel name & Amenities
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hotel['name'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hotel['amenities'] as String,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price & Discount Column
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        hotel['price'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        '/night',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        hotel['originalPrice'] as String,
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          hotel['discount'] as String,
                                          style: const TextStyle(
                                            color: Color(0xFF15803D),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Slide indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_hotelDealsList.length, (index) {
              final isCurrent = index == _currentHotelPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isCurrent ? 20 : 6,
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF9333EA) : Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // "Book hotel now" Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF9333EA).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelScreen()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Book hotel now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 8. BOOK CABS & BIKE RIDES FOR FESTIVALS
  // ==========================================
  // ==========================================
// 8. BOOK CABS & BIKE RIDES FOR FESTIVALS (Overflow Fixed)
// ==========================================
  Widget _buildRidesAndCabsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row - Overflow Fixed
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD83A3A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Color(0xFFD83A3A), size: 24),
              ),
              const SizedBox(width: 12),
              const Flexible(   // ← Yeh fix hai
                child: Text(
                  'Book Cabs & Bikes for festivals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          RichText(
            text: const TextSpan(
              text: 'Save up to ₹150 using code ',
              style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: 'FESTIVERIDE',
                  style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF4338CA), width: 1.2),
                  ),
                  child: const Column(
                    children: [
                      Text('Nov', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 2),
                      Text('Chhath & Diwali', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF4338CA), width: 1.2),
                  ),
                  child: const Column(
                    children: [
                      Text('Dec', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                      SizedBox(height: 2),
                      Text('Christmas & NY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFE4E6),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarScreen()),
                );
              },
              icon: const Icon(Icons.directions_car_rounded, size: 18, color: Color(0xFFD83A3A)),
              label: const Text(
                'Book Cabs & Bikes for festivals',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, color: Colors.blue.shade700, size: 14),
              const SizedBox(width: 6),
              Flexible(   // safety ke liye
                child: Text(
                  'Guaranteed AC • Verified Drivers • Zero Surge',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 9. COUPON CREATOR & EXCLUSIVE GIFT
  // ==========================================
  Widget _buildCouponAndGiftSection() {
    return Column(
      children: [
        // COUPON CREATOR Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF08A), Color(0xFFFDE047)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB45309),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.currency_rupee, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'COUPON CREATOR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF92400E),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Create personalised coupon for your\nguests at zero cost',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Save upto ₹400',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coupon Creator opened!')),
                    );
                  },
                  child: const Text('Create personalised coupon', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // EXCLUSIVE GIFT Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFDE8E8), Color(0xFFE9D5FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.card_giftcard, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                'Thank you for being our loyal customer',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'We have an exclusive gift for you',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎁 Congratulations! You have received ₹150 Wallet Cashback!')),
                    );
                  },
                  child: const Text('View your gift', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 10. RATE US SECTION
  // ==========================================
  Widget _buildRateUsSection() {
    const primaryRed = Color(0xFFD83A3A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate Us',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Color(0xFFFBBF24), size: 26),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Color(0xFFFBBF24), size: 10),
                              Icon(Icons.star, color: Color(0xFFFBBF24), size: 10),
                              Icon(Icons.star, color: Color(0xFFFBBF24), size: 10),
                              Icon(Icons.star, color: Color(0xFFFBBF24), size: 10),
                              Icon(Icons.star, color: Color(0xFFFBBF24), size: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enjoying SPinGO?',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Share your experience with us and help spread the word!',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you for rating SPinGO 5 Stars! ⭐⭐⭐⭐⭐')),
                      );
                    },
                    child: const Text('Rate Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 11. TOP DESTINATIONS FROM LUCKNOW (With Real HD Photos!)
  // ==========================================
  Widget _buildTopDestinationsSection() {
    final List<Map<String, dynamic>> destinations = [
      {
        'city': 'Delhi',
        'price': 'From ₹15',
        'tag': 'RTC available',
        'tagColor': const Color(0xFFEDE9FE),
        'tagTextColor': const Color(0xFF6D28D9),
        'number': '1',
        'imageUrl': 'https://images.unsplash.com/photo-1587474260584-136574528ed5?auto=format&fit=crop&w=300&q=80',
      },
      {
        'city': 'Jaipur (Rajasthan)',
        'price': 'From ₹599',
        'tag': '107+ buses',
        'tagColor': const Color(0xFFFFE4E6),
        'tagTextColor': const Color(0xFFBE123C),
        'number': '2',
        'imageUrl': 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=300&q=80',
      },
      {
        'city': 'Varanasi',
        'price': 'From ₹399',
        'tag': 'RTC available',
        'tagColor': const Color(0xFFEDE9FE),
        'tagTextColor': const Color(0xFF6D28D9),
        'number': '3',
        'imageUrl': 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=300&q=80',
      },
      {
        'city': 'Agra',
        'price': 'From ₹299',
        'tag': '85+ buses',
        'tagColor': const Color(0xFFFFE4E6),
        'tagTextColor': const Color(0xFFBE123C),
        'number': '4',
        'imageUrl': 'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=300&q=80',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Destinations',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              SizedBox(height: 2),
              Text(
                'From Lucknow',
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final item = destinations[index];
              return GestureDetector(
                onTap: () => _navigateToBookingScreen(destination: item['city'] as String),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Watermark number
                      Positioned(
                        right: 8,
                        top: 4,
                        child: Text(
                          item['number'] as String,
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: _buildHDImage(
                                      item['imageUrl'] as String,
                                      fit: BoxFit.cover,
                                      fallbackIcon: Icons.location_city,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['city'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['price'] as String,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Chip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: item['tagColor'] as Color,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                            ),
                            child: Text(
                              item['tag'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item['tagTextColor'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 12. GOVERNMENT RTC BUSES
  // ==========================================
  Widget _buildGovernmentBusesSection() {
    final rtcList = [
      {
        'code': 'APSRTC',
        'rating': '★ 3.85',
        'sub': 'ఆంధ్రప్రదేశ్ రాష్ట్ర రోడ్డు రవాణా సంస్థ',
        'color': const Color(0xFF1E3A8A),
      },
      {
        'code': 'TGSRTC',
        'rating': '★ 3.92',
        'sub': 'తెలంగాణ రాష్ట్ర రోడ్డు రవాణా సంస్థ',
        'color': const Color(0xFF15803D),
      },
      {
        'code': 'UPSRTC',
        'rating': '★ 3.78',
        'sub': 'उत्तर प्रदेश राज्य सड़क परिवहन निगम',
        'color': const Color(0xFFD97706),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Government Buses',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: rtcList.length,
            itemBuilder: (context, index) {
              final rtc = rtcList[index];
              return GestureDetector(
                onTap: () => _navigateToBookingScreen(destination: 'RTC Bus Route'),
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (rtc['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: rtc['color'] as Color, width: 1.5),
                        ),
                        child: Center(
                          child: Icon(Icons.account_balance, color: rtc['color'] as Color, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rtc['code'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    rtc['rating'] as String,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rtc['sub'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  // ==========================================
  // HD IMAGE HELPER (Crash-free with loading & fallback)
  // ==========================================
  Widget _buildHDImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? fallbackColor,
    List<Color>? fallbackGradient,
    IconData fallbackIcon = Icons.image,
  }) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: fallbackColor ?? const Color(0xFFF1F5F9),
            child: Center(
              child: Icon(fallbackIcon, color: Colors.grey.shade400, size: 24),
            ),
          );
        },
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: (fallbackColor ?? Colors.grey.shade200).withValues(alpha: 0.3),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF65A30D)),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fallbackColor ?? const Color(0xFFF1F5F9),
            gradient: fallbackGradient != null
                ? LinearGradient(
                    colors: fallbackGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Center(
            child: Icon(fallbackIcon, color: Colors.white.withValues(alpha: 0.8), size: 24),
          ),
        );
      },
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================
  void _pickCity(bool isFrom) {
    final cities = ['Delhi', 'Lucknow', 'Kanpur', 'Agra', 'Jaipur', 'Varanasi', 'Chandigarh', 'Dehradun', 'Gorakhpur', 'Prayagraj'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Select ${isFrom ? 'Origin' : 'Destination'} City', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (ctx, index) {
                    final city = cities[index];
                    return ListTile(
                      leading: const Icon(Icons.location_city, color: Color(0xFFD83A3A)),
                      title: Text(city),
                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            _fromCity = city;
                          } else {
                            _toCity = city;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _journeyDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _journeyDate = picked);
    }
  }
}
