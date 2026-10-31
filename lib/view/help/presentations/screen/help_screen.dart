import 'package:flutter/material.dart';
import 'package:tripried/view/help/presentations/widgets/faq_card.dart';
import 'package:tripried/view/help/presentations/widgets/help_guide_card.dart';
import 'package:tripried/view/help/presentations/widgets/help_illustrations.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _selectedLanguage = 'English';

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final languages = ['English', 'हिंदी (Hindi)', 'தமிழ் (Tamil)', 'తెలుగు (Telugu)', 'ಕನ್ನಡ (Kannada)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Select Help Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Divider(),
                ...languages.map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFFDC2626))
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language changed to $lang')),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFaqDetailModal(String category, List<Map<String, String>> faqs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$category FAQ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: faqs.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final faq = faqs[index];
                        return ExpansionTile(
                          title: Text(
                            faq['q']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['a']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGuideDetail(String title, String detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Text(
                detail,
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Help',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Language Switcher Badge (A / अ)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: _showLanguageSelector,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'अ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. NEED HELP WITH THIS TRIP?
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Need help with this trip?',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing all past and upcoming bookings')),
                    );
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Empty State Card: Sleeping Cat on Luggage
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CatOnLuggageIllustration(size: 115),
                  SizedBox(height: 16),
                  Text(
                    'No recent trips',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // 2. RECENT ISSUES
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent issues',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No previous issues or support tickets found')),
                    );
                  },
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Empty State Card: Open Folder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OpenFolderIllustration(size: 95),
                  SizedBox(height: 14),
                  Text(
                    'No recent issues',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==========================================
            // 3. FAQ GRID
            // ==========================================
            const Text(
              'FAQ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Grid (Bus FAQ, Train FAQ, Hotels FAQ, Metro FAQ)
            Row(
              children: [
                Expanded(
                  child: FaqCard(
                    title: 'Bus FAQ',
                    type: 'bus',
                    onTap: () => _showFaqDetailModal('Bus', [
                      {
                        'q': 'Can I cancel my bus ticket?',
                        'a': 'Yes, you can cancel your bus ticket through the My Bookings section. Cancellation charges apply as per the bus operator policy.',
                      },
                      {
                        'q': 'How do I track my bus location?',
                        'a': 'Live bus tracking link is sent via SMS and WhatsApp 30 minutes before departure time. You can also track from the active ticket screen.',
                      },
                      {
                        'q': 'What if the bus is delayed or cancelled?',
                        'a': 'If the bus operator cancels the service, you are entitled to a 100% full refund credited instantly to your source payment method.',
                      },
                    ]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FaqCard(
                    title: 'Bike & Rides FAQ',
                    type: 'bike',
                    onTap: () => _showFaqDetailModal('Bike & Rides', [
                      {
                        'q': 'How do I book a TripRied Bike Taxi?',
                        'a': 'Enter pickup and drop locations, select Bike Taxi, and confirm. Your captain arrives within minutes with a sanitized helmet.',
                      },
                      {
                        'q': 'Can I cancel my ride booking for free?',
                        'a': 'Yes, you can cancel any bike or cab booking without penalty within 5 minutes of booking before captain arrives.',
                      },
                      {
                        'q': 'How does live ride tracking work?',
                        'a': 'Track your captain live on the interactive map and share real-time ride tracking link directly with family via WhatsApp.',
                      },
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FaqCard(
                    title: 'Hotels FAQ',
                    type: 'hotels',
                    onTap: () => _showFaqDetailModal('Hotels', [
                      {
                        'q': 'What are standard hotel check-in and check-out timings?',
                        'a': 'Most hotels have check-in at 12:00 PM and check-out at 11:00 AM. Early check-in is subject to availability upon arrival.',
                      },
                      {
                        'q': 'Can I pay at the hotel during check-in?',
                        'a': 'Yes, select hotels offer "Pay at Hotel" option where you can pay via Cash, UPI, or Card upon reaching the property.',
                      },
                    ]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FaqCard(
                    title: 'Parcel Delivery FAQ',
                    type: 'parcel',
                    onTap: () => _showFaqDetailModal('Parcel Delivery', [
                      {
                        'q': 'How does instant Doorstep Parcel Delivery work?',
                        'a': 'A verified delivery partner picks up your sealed package from your doorstep and delivers it within 45-60 minutes across the city.',
                      },
                      {
                        'q': 'How is parcel handover verified securely?',
                        'a': 'The recipient must share the secret 4-digit OTP shown in your app before the courier partner can mark the parcel delivered.',
                      },
                    ]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==========================================
            // 4. BOTTOM INFORMATIONAL GUIDES CAROUSEL
            // ==========================================
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  HelpGuideCard(
                    title: 'The ticket is not automatically cancelled',
                    subtitle: 'and is still a valid ticket for your travel.',
                    visualWidget: const YellowTicketBadge(),
                    onTap: () => _showGuideDetail(
                      'Ticket Validity Policy',
                      'If a bus service is delayed or your payment confirmation took longer, your ticket is still reserved and valid. Do not book a duplicate ticket without checking your active bookings.',
                    ),
                  ),
                  HelpGuideCard(
                    title: 'ERROR! But why am I seeing this?',
                    subtitle: 'Common payment gateway & network solutions.',
                    visualWidget: const PhoneQueryGraphic(),
                    onTap: () => _showGuideDetail(
                      'Payment & Error Resolution',
                      'If money was debited from your bank account but booking failed, the amount is automatically refunded back to your account within 2-4 business hours.',
                    ),
                  ),
                  HelpGuideCard(
                    title: 'Instant Refund Guarantee',
                    subtitle: 'Money credited back to UPI within 2 hours.',
                    visualWidget: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.currency_rupee, color: Color(0xFFFACC15), size: 30),
                      ),
                    ),
                    onTap: () => _showGuideDetail(
                      'Instant Refund Policy',
                      'All eligible refunds for cancelled bookings are credited back to your original payment mode (UPI, Cards, or Wallet) seamlessly.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
