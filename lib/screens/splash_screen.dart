import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Image.asset('assets/images/logo.png', width: 200, height: 200)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500))
                .then()
                .scale(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 40),

            // Título do jogo
            const Text(
                  'Math Fun Adventure',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C6FFF),
                  ),
                )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slide(
                  begin: const Offset(0, 0.5),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                ),

            const SizedBox(height: 16),

            // Slogan
            const Text(
              'Aprenda matemática se divertindo!',
              style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
            ).animate().fadeIn(delay: const Duration(milliseconds: 600)),

            const SizedBox(height: 64),

            // Loader animado
            _buildAnimatedLoader(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return SizedBox(
      width: 120,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildDot(index),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    // Cores para cada ponto, usando as cores do tema
    final colors = [
      const Color(0xFF4C6FFF), // Azul
      const Color(0xFF42E682), // Verde
      const Color(0xFFFFD747), // Amarelo
      const Color(0xFFFF6B6B), // Vermelho
      const Color(0xFF9D71EA), // Roxo
    ];

    return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colors[index],
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scaleXY(
          begin: 0.5,
          end: 1.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          delay: Duration(milliseconds: index * 100),
        )
        .then()
        .scaleXY(
          begin: 1.0,
          end: 0.5,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
  }
}
