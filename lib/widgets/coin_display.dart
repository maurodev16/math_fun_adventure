import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CoinDisplay extends StatelessWidget {
  final int coins;
  final bool showAnimation;
  final bool large;

  const CoinDisplay({
    super.key,
    required this.coins,
    this.showAnimation = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16.0 : 12.0,
        vertical: large ? 8.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(large ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone de moeda
          _buildCoinIcon(),
          SizedBox(width: large ? 8.0 : 6.0),

          // Valor
          _buildCoinAmount(),
        ],
      ),
    );
  }

  Widget _buildCoinIcon() {
    return Container(
          width: large ? 32.0 : 24.0,
          height: large ? 32.0 : 24.0,
          decoration: const BoxDecoration(
            color: Color(0xFFFFD747),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE6B800),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '\$',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: large ? 18.0 : 14.0,
              ),
            ),
          ),
        )
        .animate(target: showAnimation ? 1 : 0)
        .shake(duration: const Duration(milliseconds: 500), hz: 4);
  }

  Widget _buildCoinAmount() {
    final displayCoins = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        coins.toString(),
        key: ValueKey<int>(coins),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: large ? 20.0 : 16.0,
          color: const Color(0xFF333333),
        ),
      ),
    );

    // Retorna o valor simples se não houver animação
    if (!showAnimation) {
      return displayCoins;
    }

    // Retorna o valor com animação se showAnimation for true
    return displayCoins.animate().scale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
    );
  }
}
