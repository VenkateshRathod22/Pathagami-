import 'package:flutter/material.dart';

class GetawaysScreen extends StatelessWidget {
  const GetawaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFD83A3A);

    final getaways = [
      {
        'name': 'Ooty',
        'state': 'Tamil Nadu',
        'tag': 'Hill Station',
        'price': 'From ₹850',
        'image': 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFF0D9488), const Color(0xFF059669)],
      },
      {
        'name': 'Mysuru',
        'state': 'Karnataka',
        'tag': 'Heritage & Palaces',
        'price': 'From ₹350',
        'image': 'https://images.unsplash.com/photo-1600100397608-f010f443b749?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFFEA580C), const Color(0xFFC2410C)],
      },
      {
        'name': 'Kodaikanal',
        'state': 'Tamil Nadu',
        'tag': 'Lakes & Waterfalls',
        'price': 'From ₹900',
        'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
      },
      {
        'name': 'Tirupati',
        'state': 'Andhra Pradesh',
        'tag': 'Pilgrimage',
        'price': 'From ₹450',
        'image': 'https://images.unsplash.com/photo-1621847468516-1ed5d0df56fe?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFFD97706), const Color(0xFFB45309)],
      },
      {
        'name': 'Manali',
        'state': 'Himachal Pradesh',
        'tag': 'Snow & Adventure',
        'price': 'From ₹1200',
        'image': 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
      },
      {
        'name': 'Rishikesh',
        'state': 'Uttarakhand',
        'tag': 'Yoga & Rafting',
        'price': 'From ₹650',
        'image': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=600&q=80',
        'gradient': [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
      },
    ];

    return Scaffold(

      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Weekend Getaways',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const BouncingScrollPhysics(),
        itemCount: getaways.length,
        itemBuilder: (context, index) {
          final item = getaways[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: item['gradient'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      );
                    },
                  ),

                  // Dark Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryRed,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['tag'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Name
                              Text(
                                item['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),

                              // State
                              Text(
                                item['state'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Price
                              Text(
                                item['price'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Explore Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryRed,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Exploring ${item['name']}...')),
                            );
                          },
                          child: const Text(
                            'Explore',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
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
    );
  }
}