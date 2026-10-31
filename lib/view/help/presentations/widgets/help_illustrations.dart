import 'package:flutter/material.dart';

/// Sleeping cat on stacked red & blue luggage with potted plant
/// as seen in the "Need help with this trip?" section of the Help screenshot.
class CatOnLuggageIllustration extends StatelessWidget {
  final double size;

  const CatOnLuggageIllustration({super.key, this.size = 130});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Potted Plant on the left
          Positioned(
            left: size * 0.1,
            bottom: 0,
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.55,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Plant leaves
                  Positioned(
                    top: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: -0.3,
                          child: Container(
                            width: size * 0.08,
                            height: size * 0.22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(size * 0.05),
                            ),
                          ),
                        ),
                        Container(
                          width: size * 0.09,
                          height: size * 0.26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(size * 0.05),
                          ),
                        ),
                        Transform.rotate(
                          angle: 0.3,
                          child: Container(
                            width: size * 0.08,
                            height: size * 0.22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(size * 0.05),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Terracotta Pot
                  Container(
                    width: size * 0.22,
                    height: size * 0.24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC2410C),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Stacked Suitcases
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sleeping Ginger Cat on Top
              SizedBox(
                width: size * 0.85,
                height: size * 0.32,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Cat Body
                    Container(
                      width: size * 0.65,
                      height: size * 0.24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    // Cat Ears
                    Positioned(
                      left: size * 0.16,
                      top: 2,
                      child: Row(
                        children: [
                          _buildEar(size),
                          SizedBox(width: size * 0.04),
                          _buildEar(size),
                        ],
                      ),
                    ),
                    // Sleeping Face details (closed eyes)
                    Positioned(
                      left: size * 0.20,
                      top: size * 0.12,
                      child: Row(
                        children: [
                          _buildClosedEye(size),
                          SizedBox(width: size * 0.04),
                          _buildClosedEye(size),
                        ],
                      ),
                    ),
                    // Relaxed Paws hanging over the red suitcase
                    Positioned(
                      right: size * 0.24,
                      bottom: -2,
                      child: Row(
                        children: [
                          Container(
                            width: size * 0.06,
                            height: size * 0.09,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(size * 0.03),
                              border: Border.all(color: const Color(0xFFEA580C), width: 0.8),
                            ),
                          ),
                          SizedBox(width: size * 0.02),
                          Container(
                            width: size * 0.06,
                            height: size * 0.09,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(size * 0.03),
                              border: Border.all(color: const Color(0xFFEA580C), width: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cat Tail
                    Positioned(
                      right: size * 0.08,
                      bottom: size * 0.08,
                      child: Container(
                        width: size * 0.12,
                        height: size * 0.06,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(size * 0.03),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top Red Suitcase
              Container(
                width: size * 0.82,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: const Color(0xFFBE123C),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.2,
                    height: size * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // Bottom Blue Suitcase
              Container(
                width: size * 0.98,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: size * 0.25,
                    height: size * 0.05,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEar(double size) {
    return Container(
      width: size * 0.06,
      height: size * 0.07,
      decoration: const BoxDecoration(
        color: Color(0xFFEA580C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  Widget _buildClosedEye(double size) {
    return Container(
      width: size * 0.04,
      height: 1.5,
      color: const Color(0xFF7C2D12),
    );
  }
}

/// Open Blue Folder with papers sticking out
/// as seen in the "Recent issues" section of the Help screenshot.
class OpenFolderIllustration extends StatelessWidget {
  final double size;

  const OpenFolderIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grey document
          Positioned(
            top: size * 0.05,
            child: Container(
              width: size * 0.58,
              height: size * 0.55,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: size * 0.25,
                    height: 4,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: size * 0.38,
                    height: 4,
                    color: const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),

          // Foreground White document sticking out tilted
          Positioned(
            top: size * 0.12,
            right: size * 0.26,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: size * 0.54,
                height: size * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: size * 0.3,
                      height: 4,
                      color: const Color(0xFF94A3B8),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: size * 0.2,
                      height: 4,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Blue Folder Front & Back
          Positioned(
            bottom: size * 0.08,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Back flap of folder
                Container(
                  width: size * 0.85,
                  height: size * 0.45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Front flap of folder (angled/folded)
                Positioned(
                  top: size * 0.08,
                  left: -size * 0.04,
                  child: Transform(
                    transform: Matrix4.skewX(-0.15),
                    child: Container(
                      width: size * 0.88,
                      height: size * 0.42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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
}

/// Custom painted/branded red outline icon badges for FAQ Grid
/// (redBus, redRail, Hotels, Metro)
class FaqIconBadge extends StatelessWidget {
  final String type; // 'bus', 'train', 'hotels', 'metro'

  const FaqIconBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFDC2626);

    switch (type.toLowerCase()) {
      case 'bus':
        // redBus style brand badge
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: redColor, width: 1.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_bus, color: redColor, size: 16),
              SizedBox(width: 4),
              Text(
                'SPinGO',
                style: TextStyle(
                  color: redColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        );

      case 'bike':
        // Bike / Rides badge
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: redColor, width: 1.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.two_wheeler_rounded, color: redColor, size: 16),
              SizedBox(width: 4),
              Text(
                'Rides',
                style: TextStyle(
                  color: redColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        );

      case 'hotels':
        // Bed with sparkles/stars
        return const SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.bed_outlined, color: redColor, size: 28),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.star, color: redColor, size: 10),
              ),
            ],
          ),
        );

      case 'parcel':
      default:
        // Parcel package box badge
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: redColor, width: 1.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined, color: redColor, size: 16),
              SizedBox(width: 4),
              Text(
                'Parcel',
                style: TextStyle(
                  color: redColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        );
    }
  }
}
