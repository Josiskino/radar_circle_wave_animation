import 'package:flutter/material.dart';

class FirstStarterScreen extends StatefulWidget {
  const FirstStarterScreen({super.key});

  @override
  State<FirstStarterScreen> createState() => _FirstStarterScreenState();
}

class _FirstStarterScreenState extends State<FirstStarterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _centerCircleAnimation;
  late Animation<double> _middleCircleAnimation;
  late Animation<double> _outerCircleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // Durée totale de l'animation
    );

    // Animation pour le cercle central (commence immédiatement, finit à 20% du temps total)
    _centerCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    // Animation pour le cercle intermédiaire (commence à 15%, finit à 50% du temps total)
    _middleCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOut),
      ),
    );

    // Animation pour le cercle externe (commence à 40%, finit à 80% du temps total)
    _outerCircleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Démarrer l'animation en boucle
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121926), // Couleur de fond sombre
      body: Stack(
        children: [
          // Animation des cercles
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(screenSize.width, screenSize.height),
                painter: PulseCirclesPainter(
                  centerProgress: _centerCircleAnimation.value,
                  middleProgress: _middleCircleAnimation.value,
                  outerProgress: _outerCircleAnimation.value,
                ),
              );
            },
          ),

          // Cercle central avec icône
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF56FF6B).withOpacity(0.4),
                  width: 1.8,
                ),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    const Color(0xFF1E3A5F).withOpacity(0.3),
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter pour dessiner les cercles concentriques avec animation de pulsation
class PulseCirclesPainter extends CustomPainter {
  final double centerProgress;
  final double middleProgress;
  final double outerProgress;

  PulseCirclesPainter({
    required this.centerProgress,
    required this.middleProgress,
    required this.outerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Couleurs
    final blueColor = Color(0xFF1E3A5F);
    final borderColorMiddle = Color(0xFF1E3A5F).withOpacity(0.4);
    final borderColorOuter = Color(0xFF1E3A5F).withOpacity(0.25);
    final accentColor = Color(0xFF56FF6B).withOpacity(0.3); // Couleur verte pour les pulsations

    // Rayon de base du cercle central et variation pour l'animation
    final baseCenterRadius = 80.0;
    final centerPulseRadius = baseCenterRadius * (1 + centerProgress * 0.05);

    // Rayon de base du cercle intermédiaire et variation pour l'animation
    final baseMiddleRadius = 160.0;
    final middlePulseRadius = baseMiddleRadius * (1 + middleProgress * 0.08);

    // Rayon de base du cercle externe et variation pour l'animation
    final baseOuterRadius = size.width * 0.65;
    final outerPulseRadius = baseOuterRadius * (1 + outerProgress * 0.1);

    // Effet de pulse pour le cercle central
    if (centerProgress > 0) {
      final pulsePaint = Paint()
        ..color = accentColor.withOpacity((1 - centerProgress) * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * centerProgress;
      canvas.drawCircle(Offset(centerX, centerY), centerPulseRadius, pulsePaint);
    }

    // Cercle externe - grand pour dépasser partiellement l'écran
    final paintOuter = Paint()
      ..color = blueColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), baseOuterRadius, paintOuter);

    // Bordure du cercle externe
    final paintOuterBorder = Paint()
      ..color = borderColorOuter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), baseOuterRadius, paintOuterBorder);

    // Effet de pulse pour le cercle externe
    if (outerProgress > 0) {
      final pulsePaint = Paint()
        ..color = accentColor.withOpacity((1 - outerProgress) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * outerProgress;
      canvas.drawCircle(Offset(centerX, centerY), outerPulseRadius, pulsePaint);
    }

    // Cercle intermédiaire
    final paintMiddle = Paint()
      ..color = blueColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), baseMiddleRadius, paintMiddle);

    // Bordure du cercle intermédiaire
    final paintMiddleBorder = Paint()
      ..color = borderColorMiddle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), baseMiddleRadius, paintMiddleBorder);

    // Effet de pulse pour le cercle intermédiaire
    if (middleProgress > 0) {
      final pulsePaint = Paint()
        ..color = accentColor.withOpacity((1 - middleProgress) * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * middleProgress;
      canvas.drawCircle(Offset(centerX, centerY), middlePulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PulseCirclesPainter oldDelegate) =>
      oldDelegate.centerProgress != centerProgress ||
      oldDelegate.middleProgress != middleProgress ||
      oldDelegate.outerProgress != outerProgress;
}