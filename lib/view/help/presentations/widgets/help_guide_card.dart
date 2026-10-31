import 'package:flutter/material.dart';

class HelpGuideCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget visualWidget;
  final VoidCallback onTap;

  const HelpGuideCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.visualWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF991B1B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Subtle background wave circle
              Positioned(
                top: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Content Row
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Graphic / Ticket on Left
                    visualWidget,
                    const SizedBox(width: 12),

                    // Texts on Right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yellow Ticket Graphic with "TICKET ★★★"
class YellowTicketBadge extends StatelessWidget {
  const YellowTicketBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFACC15),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'TICKET',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.star, size: 8, color: Color(0xFF1E293B)),
              SizedBox(width: 2),
              Icon(Icons.star, size: 8, color: Color(0xFF1E293B)),
              SizedBox(width: 2),
              Icon(Icons.star, size: 8, color: Color(0xFF1E293B)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Phone & Avatar Graphic with "?" Question Mark
class PhoneQueryGraphic extends StatelessWidget {
  const PhoneQueryGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 65,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // White Phone Outline
          Positioned(
            left: 0,
            child: Container(
              width: 32,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black87, width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 22,
                  height: 38,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),

          // Woman Cartoon Avatar
          Positioned(
            right: 4,
            bottom: 0,
            child: Container(
              width: 34,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF4C1D95),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFED7AA),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Yellow Question Mark
          const Positioned(
            top: 2,
            right: 0,
            child: Text(
              '?',
              style: TextStyle(
                color: Color(0xFFFACC15),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
