import 'package:flutter/material.dart';

/// Highly optimized Spingo Brand Logo Widget
/// Loads the exact asset provided by the user with fallback styling
class SpingoLogo extends StatelessWidget {
  final double height;
  final bool isDark; // True for dark background (white SPN), false for white background (dark SPN)

  const SpingoLogo({
    super.key,
    this.height = 30,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = isDark
        ? 'assets/images/spingo_logo.png'
        : 'assets/images/spingo_logo_dark.png';

    return Image.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // High quality fallback vector rendering in case asset loading is delayed
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'SP',
              style: TextStyle(
                fontSize: height * 0.75,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            // 'i' with green antenna / swirl dot
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'i',
                  style: TextStyle(
                    fontSize: height * 0.75,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF84CC16),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: height * 0.2,
                    height: height * 0.2,
                    decoration: const BoxDecoration(
                      color: Color(0xFF84CC16),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'N',
              style: TextStyle(
                fontSize: height * 0.75,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'G',
              style: TextStyle(
                fontSize: height * 0.75,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF84CC16),
              ),
            ),
            // 'O' with location pin inside
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'O',
                  style: TextStyle(
                    fontSize: height * 0.75,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF84CC16),
                  ),
                ),
                Icon(
                  Icons.location_on,
                  size: height * 0.38,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
