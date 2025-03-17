import 'package:flutter/material.dart';
import 'dart:math' as math;

class ThirdStarterScreen extends StatefulWidget {
  const ThirdStarterScreen({super.key});

  @override
  State<ThirdStarterScreen> createState() => _ThirdStarterScreenState();
}

class _ThirdStarterScreenState extends State<ThirdStarterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation - plus lente pour un effet plus fluide
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Durée totale plus longue
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
                painter: RadarPulseCirclesPainter(
                  animationValue: _animationController.value,
                ),
              );
            },
          ),

          // Cercle central avec icône
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Calcul de l'opacité de la bordure (diminue au début, reste faible pendant la majeure partie de l'animation, puis revient à la fin)
                double borderOpacity = 0.4;
                if (_animationController.value < 0.1) {
                  // Diminue rapidement pendant les premiers 10% de l'animation
                  borderOpacity = 0.4 * (1 - (_animationController.value * 10));
                } else if (_animationController.value > 0.9) {
                  // Revient progressivement pendant les derniers 10% de l'animation
                  borderOpacity = 0.4 * (((_animationController.value - 0.9) * 10));
                } else {
                  // Reste à opacité très faible pendant 80% de l'animation
                  borderOpacity = 0.05;
                }
                
                return Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF56FF6B).withOpacity(borderOpacity),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter pour dessiner l'effet radar
class RadarPulseCirclesPainter extends CustomPainter {
  final double animationValue;

  RadarPulseCirclesPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Couleurs
    final blueColor = Color(0xFF1E3A5F);
    final accentColor = Color(0xFF56FF6B);

    // Rayons de base des cercles
    final baseCenterRadius = 70.0; // Un peu plus petit que le conteneur central (140/2)
    final baseMiddleRadius = 160.0;
    final baseOuterRadius = size.width * 0.65;

    // Rayon maximal de la vague radar (légèrement plus grand que le cercle externe)
    final maxWaveRadius = baseOuterRadius * 1.1;
    
    // Calcul du rayon actuel de la vague radar
    final currentWaveRadius = baseCenterRadius + (maxWaveRadius - baseCenterRadius) * animationValue;

    // Dessiner les cercles statiques
    
    // Cercle externe
    final paintOuter = Paint()
      ..color = blueColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), baseOuterRadius, paintOuter);
    
    // Bordure du cercle externe - opacité qui varie selon la proximité de la vague
    double outerBorderOpacity = calculateBorderOpacity(baseOuterRadius, currentWaveRadius, 30);
    final paintOuterBorder = Paint()
      ..color = blueColor.withOpacity(0.25 * outerBorderOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), baseOuterRadius, paintOuterBorder);

    // Cercle intermédiaire
    final paintMiddle = Paint()
      ..color = blueColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), baseMiddleRadius, paintMiddle);
    
    // Bordure du cercle intermédiaire - opacité qui varie selon la proximité de la vague
    double middleBorderOpacity = calculateBorderOpacity(baseMiddleRadius, currentWaveRadius, 25);
    final paintMiddleBorder = Paint()
      ..color = blueColor.withOpacity(0.4 * middleBorderOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(centerX, centerY), baseMiddleRadius, paintMiddleBorder);
    
    // Effet de vague radar
    // Calculer l'opacité de la vague en fonction de sa progression (diminue plus elle s'éloigne)
    final waveProgress = (currentWaveRadius - baseCenterRadius) / (maxWaveRadius - baseCenterRadius);
    final waveOpacity = math.max(0, 0.8 - waveProgress * 0.8);
    
    // Dessiner la vague radar
    final wavePaint = Paint()
      ..color = accentColor.withOpacity(waveOpacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3); // Effet de flou pour un rendu plus doux
    
    canvas.drawCircle(Offset(centerX, centerY), currentWaveRadius, wavePaint);
    
    // Ajouter un second anneau plus flou pour un effet de profondeur
    final secondaryWavePaint = Paint()
      ..color = accentColor.withOpacity(waveOpacity * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawCircle(Offset(centerX, centerY), currentWaveRadius - 4, secondaryWavePaint);
  }
  
  // Calculer l'opacité de la bordure en fonction de la proximité de la vague radar
  double calculateBorderOpacity(double borderRadius, double waveRadius, double effectRange) {
    // Distance entre la vague et le bord du cercle
    final distance = (borderRadius - waveRadius).abs();
    
    // Si la vague est proche du cercle, augmenter l'opacité
    if (distance < effectRange) {
      // Transition douce de l'opacité
      final effectFactor = 1 - (distance / effectRange);
      return 1 + effectFactor * 0.5; // Amplifier l'opacité jusqu'à 150%
    }
    
    return 1.0; // Opacité de base
  }

  @override
  bool shouldRepaint(covariant RadarPulseCirclesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}