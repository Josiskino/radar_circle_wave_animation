import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarterScreen extends StatefulWidget {
  const StarterScreen({super.key});

  @override
  State<StarterScreen> createState() => _StarterScreenState();
}

class _StarterScreenState extends State<StarterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<double> _waveRadiuses = []; // Pour stocker plusieurs vagues
  final int _waveCount = 3; // Nombre de vagues
  final double _waveInterval = 0.33; // Intervalle entre les vagues

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation avec une durée plus longue
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000), // Durée plus longue pour mieux apprécier l'effet
    );

    // Initialiser les positions des vagues espacées régulièrement
    for (int i = 0; i < _waveCount; i++) {
      _waveRadiuses.add(i * _waveInterval);
    }

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
                painter: RadarPulseCirclesPainter(
                  animationValue: _animationController.value,
                  waveRadiuses: _waveRadiuses,
                ),
              );
            },
          ),

          // Cercle central avec icône
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Animation de pulsation pour le cercle central
                final pulseFactor = 1.0 + 0.05 * math.sin(_animationController.value * 2 * math.pi);
                
                return Container(
                  width: 140 * pulseFactor,
                  height: 140 * pulseFactor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(
                        const Color(0xFF56FF6B).withOpacity(0.3),
                        const Color(0xFF56FF6B).withOpacity(0.8),
                        math.sin(_animationController.value * 2 * math.pi) * 0.5 + 0.5,
                      )!,
                      width: 2.0,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.5 * (math.sin(_animationController.value * 2 * math.pi) * 0.3 + 0.7)),
                        const Color(0xFF1E3A5F).withOpacity(0.3),
                      ],
                      stops: const [0.1, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF56FF6B).withOpacity(0.3 * (math.sin(_animationController.value * 2 * math.pi) * 0.5 + 0.5)),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.send,
                      color: Colors.white.withOpacity(0.7 + 0.3 * math.sin(_animationController.value * 2 * math.pi)),
                      size: 36,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter pour dessiner l'effet radar amélioré
class RadarPulseCirclesPainter extends CustomPainter {
  final double animationValue;
  final List<double> waveRadiuses;

  RadarPulseCirclesPainter({
    required this.animationValue,
    required this.waveRadiuses,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Couleurs
    final blueColor = Color(0xFF1E3A5F);
    final accentColor = Color(0xFF56FF6B);

    // Rayons de base des cercles
    final baseCenterRadius = 70.0;
    final baseMiddleRadius = 160.0;
    final baseOuterRadius = size.width * 0.65;

    // Rayon maximal des vagues
    final maxWaveRadius = baseOuterRadius * 1.2;
    
    // Facteur d'apparition des cercles fixes (cercle moyen et grand cercle)
    // Ils apparaissent progressivement pendant la première moitié de l'animation
    final middleCircleOpacity = math.min(1.0, animationValue * 3); // Apparaît sur le premier tiers
    final outerCircleOpacity = math.min(1.0, math.max(0, (animationValue * 3) - 1)); // Apparaît sur le deuxième tiers

    // Animation d'échelle pour les cercles fixes
    final middleCircleScale = math.min(1.0, animationValue * 5); // Grandit plus rapidement
    final outerCircleScale = math.min(1.0, math.max(0, (animationValue * 4) - 0.5)); // Commence un peu plus tard
    
    final currentMiddleRadius = baseMiddleRadius * middleCircleScale;
    final currentOuterRadius = baseOuterRadius * outerCircleScale;

    // Dessiner les cercles externes avec animation d'apparition
    
    // Dessiner le cercle externe avec opacité progressive
    if (outerCircleOpacity > 0) {
      // Effet de respiration sur le cercle externe
      final outerBreathEffect = 1.0 + 0.03 * math.sin(animationValue * 2 * math.pi);
      
      final paintOuter = Paint()
        ..color = blueColor.withOpacity(0.1 * outerCircleOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), currentOuterRadius * outerBreathEffect, paintOuter);
      
      // Bordure du cercle externe avec glow
      final paintOuterBorder = Paint()
        ..color = blueColor.withOpacity(0.25 * outerCircleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(centerX, centerY), currentOuterRadius * outerBreathEffect, paintOuterBorder);
      
      // Ajouter un effet de glow pendant l'apparition
      if (outerCircleOpacity < 1.0) {
        final glowPaint = Paint()
          ..color = accentColor.withOpacity(0.15 * (1 - outerCircleOpacity))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(centerX, centerY), currentOuterRadius * outerBreathEffect, glowPaint);
      }
    }

    // Dessiner le cercle intermédiaire avec opacité progressive
    if (middleCircleOpacity > 0) {
      // Effet de respiration sur le cercle moyen (décalé par rapport au cercle externe)
      final middleBreathEffect = 1.0 + 0.04 * math.sin((animationValue + 0.3) * 2 * math.pi);
      
      final paintMiddle = Paint()
        ..color = blueColor.withOpacity(0.2 * middleCircleOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), currentMiddleRadius * middleBreathEffect, paintMiddle);
      
      // Bordure du cercle intermédiaire
      final paintMiddleBorder = Paint()
        ..color = blueColor.withOpacity(0.4 * middleCircleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(centerX, centerY), currentMiddleRadius * middleBreathEffect, paintMiddleBorder);
      
      // Ajouter un effet de glow pendant l'apparition
      if (middleCircleOpacity < 1.0) {
        final glowPaint = Paint()
          ..color = accentColor.withOpacity(0.2 * (1 - middleCircleOpacity))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(centerX, centerY), currentMiddleRadius * middleBreathEffect, glowPaint);
      }
    }
    
    // Dessiner chaque vague d'animation
    for (int i = 0; i < waveRadiuses.length; i++) {
      // Calculer la position normalisée de cette vague (entre 0 et 1)
      double normalizedPosition = (animationValue + (i * 1.0 / waveRadiuses.length)) % 1.0;
      
      // Calculer le rayon actuel de la vague
      double currentRadius = baseCenterRadius + (maxWaveRadius - baseCenterRadius) * normalizedPosition;
      
      // Calculer l'opacité de la vague (diminue à mesure qu'elle s'éloigne)
      double waveOpacity = math.max(0, 0.9 - normalizedPosition * 0.9);
      
      // Variation de l'intensité entre les vagues
      double intensityVariation = 0.7 + 0.3 * math.sin(i * math.pi / waveRadiuses.length);
      
      // Calculer la largeur de la vague (plus fine au début, plus large à mesure qu'elle s'éloigne)
      double strokeWidth = 1.5 + normalizedPosition * 4;
      
      // Dessiner la vague principale
      final wavePaint = Paint()
        ..color = accentColor.withOpacity(waveOpacity * 0.5 * intensityVariation)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + normalizedPosition * 4);
      
      canvas.drawCircle(Offset(centerX, centerY), currentRadius, wavePaint);
      
      // Dessiner une vague secondaire légèrement décalée pour un effet de profondeur
      final secondaryWavePaint = Paint()
        ..color = accentColor.withOpacity(waveOpacity * 0.25 * intensityVariation)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.5
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + normalizedPosition * 5);
      
      canvas.drawCircle(Offset(centerX, centerY), currentRadius - 2, secondaryWavePaint);
      
      // Ajouter un effet de "flash" lorsque l'onde atteint les cercles moyen et externe
      if (currentMiddleRadius > 0 && (currentRadius - currentMiddleRadius).abs() < 15) {
        double flashIntensity = 1.0 - ((currentRadius - currentMiddleRadius).abs() / 15);
        final flashPaint = Paint()
          ..color = accentColor.withOpacity(0.3 * flashIntensity * middleCircleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(centerX, centerY), currentMiddleRadius, flashPaint);
      }
      
      if (currentOuterRadius > 0 && (currentRadius - currentOuterRadius).abs() < 20) {
        double flashIntensity = 1.0 - ((currentRadius - currentOuterRadius).abs() / 20);
        final flashPaint = Paint()
          ..color = accentColor.withOpacity(0.25 * flashIntensity * outerCircleOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(Offset(centerX, centerY), currentOuterRadius, flashPaint);
      }
    }
    
    // Ajouter un léger glow constant au centre
    final centerGlowPaint = Paint()
      ..color = accentColor.withOpacity(0.15 + 0.1 * math.sin(animationValue * 2 * math.pi))
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(centerX, centerY), baseCenterRadius * 0.8, centerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant RadarPulseCirclesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}