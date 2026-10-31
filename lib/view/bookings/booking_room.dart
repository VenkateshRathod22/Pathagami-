import 'package:flutter/material.dart';
import 'package:tripried/view/common/widgets/spingo_logo.dart';
import 'package:tripried/view/help/presentations/screen/help_screen.dart';
import 'package:tripried/view/offers/presentations/screen/offers_splash_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/presentations/screen/wallet_screen.dart';
import 'package:tripried/view/account/sub_features/wallet/services/wallet_service.dart';

class BookingRoom extends StatefulWidget {
  const BookingRoom({super.key});

  @override
  State<BookingRoom> createState() => _BookingRoomState();
}

class _BookingRoomState extends State<BookingRoom> {
  int _selectedCategoryIndex = 3; // Hotel selected by default
  bool _isHourlyStays = false;
  String _selectedCity = 'Near me';
  int _currentNavIndex = 1; // Bookings tab active

  static const Color primaryRed = Color(0xFFD83A3A);

  @override
  void initState() {
    super.initState();
    WalletService.instance.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    WalletService.instance.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    if (mounted) setState(() {});
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
              // 1. TOP HEADER (SPinGO logo, Wallet, My Account)
              _buildTopHeader(),

              const SizedBox(height: 10),

              // 2. CATEGORY PILLS (Bus, Train, Hotel)
              _buildCategoryPills(),

              const SizedBox(height: 16),

              // 3. HERO TITLE & SEARCH SECTION
              _buildHeroAndSearchCard(),

              const SizedBox(height: 14),

              // 4. HOURLY STAYS CARD
              _buildHourlyStaysCard(),

              const SizedBox(height: 14),

              // 5. SEARCH BUTTON
              _buildSearchButton(),

              const SizedBox(height: 28),

              // 6. THE BUDGET COLLECTION
              _buildBudgetCollection(),

              const SizedBox(height: 28),

              // 7. VALUE STAYS
              _buildValueStays(),

              const SizedBox(height: 28),

              // 8. TOP HOTEL BRANDS
              _buildTopHotelBrands(),

              const SizedBox(height: 28),

              // 9. ONLY ON SPINGO OFFERS
              _buildOnlyOnSpingoOffers(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

// 1. TOP HEADER (Final Overflow Fix - 31px resolved)
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          // Left side
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Navigator.canPop(context)) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.arrow_back_ios_new, size: 17, color: Colors.black87),
                  ),
                ),
              ],
              const SpingoLogo(height: 26),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'HOTELS',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Right side - now more compact
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: _buildHeaderPill(
                      icon: Icons.account_balance_wallet_outlined,
                      text: 'Wallet ₹${WalletService.instance.balance.toStringAsFixed(0)}',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _buildHeaderPill(
                    icon: Icons.person_outline,
                    text: 'Account',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. CATEGORY PILLS (Bus, Train, Hotel)
  Widget _buildCategoryPills() {
    final categories = [
      {
        'name': 'Bus',
        'offer': '₹300 off',
        'icon': Icons.directions_bus,
        'image': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=120&q=80',
      },
      {
        'name': 'Bike',
        'offer': '30% Off',
        'icon': Icons.two_wheeler,
        'image': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=120&q=80',
      },
      {
        'name': 'Car',
        'offer': 'From ₹9/km',
        'icon': Icons.directions_car,
        'image': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=120&q=80',
      },
      {
        'name': 'Hotel',
        'offer': 'Save 70%',
        'icon': Icons.hotel,
        'image': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=120&q=80',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          final cat = categories[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                margin: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? primaryRed : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        cat['image'] as String,
                        width: 30,
                        height: 26,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(cat['icon'] as IconData, size: 20, color: isSelected ? primaryRed : const Color(0xFF64748B)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          cat['offer'] as String,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 3. HERO TITLE & SEARCH CARD
  Widget _buildHeroAndSearchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline & Illustration Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Budget rooms in\ntop locations',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ),
              ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFEF3C7),
                    ),
                    child: const Icon(Icons.person, size: 48, color: Color(0xFFD97706)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Floating Search Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Blue top banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 15),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verified reviews & ratings', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('30000+ affordable stays', style: TextStyle(color: Colors.white70, fontSize: 9.5)),
                        ],
                      ),
                    ],
                  ),
                ),

                // City / Location selector
                ListTile(
                  leading: const Icon(Icons.search, color: Color(0xFF0F172A), size: 24),
                  title: const Text('City, area or hotel name', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  subtitle: Text(
                    _selectedCity,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ['Near me', 'Mumbai', 'Delhi', 'Bengaluru', 'Goa', 'Jaipur'].map((city) {
                            return ListTile(
                              title: Text(city, style: const TextStyle(fontWeight: FontWeight.bold)),
                              onTap: () {
                                setState(() => _selectedCity = city);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Check-in & Check-out row
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: Color(0xFF0F172A), size: 20),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check in', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            SizedBox(height: 2),
                            Text('21 Oct, Wed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check out', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                            SizedBox(height: 2),
                            Text('22 Oct, Thu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Rooms & Guests row
                const ListTile(
                  leading: Icon(Icons.people_outline, color: Color(0xFF0F172A), size: 22),
                  title: Text('No. of rooms & guests', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  subtitle: Text('1 room · 1 Adult · 0 Children', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. HOURLY STAYS CARD
  Widget _buildHourlyStaysCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Color(0xFF0F172A), size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hourly stays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text('Book room for 3/6/9 hours', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch(
            value: _isHourlyStays,
            activeTrackColor: primaryRed,
            onChanged: (val) => setState(() => _isHourlyStays = val),
          ),
        ],
      ),
    );
  }

  // 5. SEARCH BUTTON
  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Searching hotels in $_selectedCity...')),
            );
          },
          child: const Text(
            'Search',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // 6. THE BUDGET COLLECTION
  Widget _buildBudgetCollection() {
    final cards = [
      {'price': 'Under\n₹999', 'color': const Color(0xFF3B82F6), 'img': 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=400&q=80'},
      {'price': 'Under\n₹799', 'color': const Color(0xFF2563EB), 'img': 'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=400&q=80'},
      {'price': 'Under\n₹499', 'color': const Color(0xFF7C3AED), 'img': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=400&q=80'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Budget Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              SizedBox(height: 2),
              Text('Rooms cheaper than your bus tickets, nearby', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final c = cards[index];
              return Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(c['img'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                          color: c['color'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c['price'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. VALUE STAYS
  Widget _buildValueStays() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Value Stays', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          const Text('For travellers who love to save', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Tall Card: Hotels
              Expanded(
                flex: 1,
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=500&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hotels', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Affordable & comfortable\nrooms', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: primaryRed, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Upto 35% off', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right Two Stacked Cards: Hostels & Homestays
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildSmallStayCard(
                      title: 'Hostels',
                      desc: 'Happy deals on dorm rooms',
                      tag: 'Upto 45% off',
                      img: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=400&q=80',
                    ),
                    const SizedBox(height: 10),
                    _buildSmallStayCard(
                      title: 'Homestays',
                      desc: 'Perfect for group bookings',
                      tag: 'Upto 40% off',
                      img: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=400&q=80',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStayCard({required String title, required String desc, required String tag, required String img}) {
    return Container(
      height: 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: primaryRed, borderRadius: BorderRadius.circular(6)),
              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 8. TOP HOTEL BRANDS
  Widget _buildTopHotelBrands() {
    final brands = [
      {'name': 'OYO', 'price': 'Starts from ₹399', 'cities': '550+ cities', 'bg': const Color(0xFFEF4444)},
      {'name': 'fab\nHOTELS', 'price': 'Starts from ₹699', 'cities': '100+ cities', 'bg': const Color(0xFF1E293B)},
      {'name': 'treebo', 'price': 'Starts from ₹1199', 'cities': '100+ cities', 'bg': const Color(0xFF6B21A8)},
      {'name': 'bloom', 'price': 'Starts from ₹1799', 'cities': '15+ cities', 'bg': const Color(0xFFEAB308)},
      {'name': 'goSTOPS', 'price': 'Starts from ₹299', 'cities': '23+ cities', 'bg': const Color(0xFFE11D48)},
      {'name': 'THE HOSTELLER', 'price': 'Starts from ₹299', 'cities': '35+ cities', 'bg': const Color(0xFFFACC15)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Hotel Brands', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          const Text('Trusted stays across India', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brands.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final b = brands[index];
              final isYellow = b['bg'] == const Color(0xFFEAB308) || b['bg'] == const Color(0xFFFACC15);
              final textColor = isYellow ? const Color(0xFF0F172A) : Colors.white;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: b['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      b['name'] as String,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['price'] as String, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(b['cities'] as String, style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 10)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward, size: 14, color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 9. ONLY ON SPINGO OFFERS
  Widget _buildOnlyOnSpingoOffers() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFACC15).withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Only on SPinGO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text('Exclusive offers for you', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildOfferCard(
                  tag: 'Hotel',
                  title: 'Flat 15% Instant Off',
                  validity: 'Valid till: 31 Dec',
                  code: 'REDSTAYS',
                  imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=200&q=80',
                ),
                const SizedBox(width: 12),
                _buildOfferCard(
                  tag: 'Hotel',
                  title: '12% Off in South Stays',
                  validity: 'Valid till: 31 Dec',
                  code: 'PILGRIMAGE',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String tag,
    required String title,
    required String validity,
    required String code,
    String? imageUrl,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text(validity, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 13, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 10. BOTTOM NAVIGATION BAR
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryRed,
      unselectedItemColor: const Color(0xFF64748B),
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      onTap: (index) {
        setState(() => _currentNavIndex = index);
        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OffersSplashScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.percent), label: 'Offers'),
        BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: 'Getaways'),
        BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Help'),
      ],
    );
  }
}
