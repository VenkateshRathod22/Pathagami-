import 'package:flutter/material.dart';

class MaxxSavingsCard extends StatelessWidget {
  final String primoOfferTitle;
  final String totalSavings;
  final String exclusiveDiscount;
  final String promoDiscount;
  final String busOperator;
  final String rating;
  final String ratingCount;
  final String busType;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String seatsAvailable;
  final String originalPrice;
  final String discountedPrice;
  final VoidCallback? onTap;

  const MaxxSavingsCard({
    super.key,
    this.primoOfferTitle = 'Primo offer:PRIMODAY',
    this.totalSavings = 'Save up to ₹747.70',
    this.exclusiveDiscount = '₹374',
    this.promoDiscount = '₹373.70',
    this.busOperator = 'GR TRANS (GRT)',
    this.rating = '4.1',
    this.ratingCount = '313',
    this.busType = 'Volvo 9600 SLX Multi-Axle AC Sleeper (2+1)',
    this.departureTime = '23:55',
    this.arrivalTime = '08:20',
    this.duration = '8h 25m',
    this.seatsAvailable = '8 Seats',
    this.originalPrice = '₹3,737',
    this.discountedPrice = '₹2,989.30',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================
          // TIER 1: Purple Combo Offer Header
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B0E4C), Color(0xFF400A38)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Primo Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Primo',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Combine 2 offers &
                const Text(
                  'Combine 2 offers &',
                  style: TextStyle(
                    color: Color(0xFFFEF08A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),

                // Save up to ₹747.70
                Text(
                  totalSavings,
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Breakdown Box with Divider & "+"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Exclusive
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Exclusive',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            exclusiveDiscount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      // Divider with "+" circle
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Divider(
                            color: Colors.white.withValues(alpha: 0.25),
                            height: 16,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 18),
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Row 2: Primo offer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            primoOfferTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            promoDiscount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // TIER 2: Bottom Bus Details Card
          // ==========================================
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Operator name & Rating Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          busOperator,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15803D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              rating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratingCount,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Bus Subtitle
                  Text(
                    busType,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Time & Duration
                  Row(
                    children: [
                      Text(
                        departureTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('—', style: TextStyle(color: Color(0xFF94A3B8))),
                      ),
                      Text(
                        arrivalTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      // Price section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            originalPrice,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFDC2626),
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA7F3D0),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF059669), width: 0.8),
                            ),
                            child: Text(
                              discountedPrice,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Duration & Seats
                  Text(
                    '$duration  •  $seatsAvailable',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
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
}
