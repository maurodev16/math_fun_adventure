import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Conjunto de widgets compartilhados para uso em todo o aplicativo
/// Isso permite manter uma aparência consistente e facilitar atualizações

// Botão personalizado do jogo
class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final bool isLarge;
  final bool isOutlined;
  final IconData? icon;
  final bool disabled;

  const GameButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = const Color(0xFF4C6FFF),
    this.isLarge = false,
    this.isOutlined = false,
    this.icon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 32.0 : 16.0,
            vertical: isLarge ? 16.0 : 12.0,
          ),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(isLarge ? 24.0 : 16.0),
            border: isOutlined ? Border.all(color: color, width: 2.0) : null,
            boxShadow:
                isOutlined
                    ? null
                    : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isOutlined ? color : Colors.white,
                  size: isLarge ? 24.0 : 18.0,
                ),
                SizedBox(width: isLarge ? 12.0 : 8.0),
              ],
              Text(
                text,
                style: TextStyle(
                  color: isOutlined ? color : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isLarge ? 18.0 : 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cartão de nível para a tela do mapa
class LevelCard extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final int stars;
  final VoidCallback onTap;
  final Color themeColor;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.stars,
    required this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCompleted
                      ? themeColor
                      : (isUnlocked ? Colors.white : Colors.grey.shade300),
              border: Border.all(
                color:
                    isCurrent
                        ? themeColor
                        : (isCompleted ? Colors.white : Colors.grey.shade400),
                width: isCurrent ? 3 : 1,
              ),
              boxShadow:
                  isCurrent || isCompleted
                      ? [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Número do nível
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      levelNumber.toString(),
                      style: TextStyle(
                        color:
                            isCompleted
                                ? Colors.white
                                : (isUnlocked ? themeColor : Colors.grey),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    if (isUnlocked && !isCompleted && levelName.isNotEmpty)
                      Text(
                        levelName,
                        style: TextStyle(
                          color: isUnlocked ? Colors.black54 : Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),

                // Ícone de bloqueado se não estiver desbloqueado
                if (!isUnlocked)
                  const Icon(Icons.lock, color: Colors.grey, size: 20),

                // Ícone de completo se estiver completo
                if (isCompleted)
                  const Positioned(
                    bottom: 5,
                    right: 5,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),

                // Estrelas do nível, se tiver
                if (stars > 0 && !isCurrent)
                  Positioned(
                    top: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Icon(
                          Icons.star,
                          color:
                              index < stars
                                  ? const Color(0xFFFFD747)
                                  : Colors.grey.shade300,
                          size: 10,
                        );
                      }),
                    ),
                  ),
              ],
            ),
          )
          .animate(target: isCurrent ? 1 : 0)
          .scale(
            duration: const Duration(milliseconds: 300),
            begin: Offset(1.0, 1.0),
            end: Offset(1.05, 1.05),
          ),
    );
  }
}

// Barra de progresso animada
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;
  final String? label;
  final bool showPercentage;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8.0,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        Stack(
          children: [
            // Fundo
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progresso
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: height,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Card de conquista
class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconAsset;
  final bool isUnlocked;
  final String? unlockDate;
  final int rewardCoins;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.isUnlocked,
    this.unlockDate,
    required this.rewardCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isUnlocked
                    ? const Color(0xFFFFD747).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            isUnlocked
                ? Border.all(color: const Color(0xFFFFD747), width: 2)
                : null,
      ),
      child: Stack(
        children: [
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        isUnlocked
                            ? const Color(0xFFFFD747)
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow:
                        isUnlocked
                            ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFD747,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    iconAsset,
                    color: isUnlocked ? Colors.white : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),

                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isUnlocked
                                  ? const Color(0xFF333333)
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isUnlocked
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                        ),
                      ),
                      if (isUnlocked && unlockDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Desbloqueado em $unlockDate',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Recompensa
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color:
                              isUnlocked
                                  ? const Color(0xFFFFD747)
                                  : Colors.grey.shade400,
                          size: 20,
                        ),
                        Text(
                          rewardCoins.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                isUnlocked
                                    ? const Color(0xFF333333)
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge de desbloqueado
          if (isUnlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD747),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// Botão de mundo no mapa
class WorldButton extends StatelessWidget {
  final int worldId;
  final String worldName;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const WorldButton({
    super.key,
    required this.worldId,
    required this.worldName,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
            width: 120,
            decoration: BoxDecoration(
              color:
                  isUnlocked
                      ? (isCurrent ? color : Colors.white)
                      : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
              border:
                  isCurrent ? Border.all(color: Colors.white, width: 2) : null,
              boxShadow:
                  isCurrent
                      ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone do mundo
                Icon(
                  icon,
                  color:
                      isUnlocked
                          ? (isCurrent ? Colors.white : color)
                          : Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),

                // Nome do mundo
                Text(
                  worldName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        isUnlocked
                            ? (isCurrent ? Colors.white : Colors.black87)
                            : Colors.grey,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),

                // Indicador de completado
                if (isCompleted && !isCurrent)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
              ],
            ),
          )
          .animate(target: isCurrent ? 1 : 0)
          .scale(
            duration: const Duration(milliseconds: 300),
            begin: Offset(1.0, 1.0),
            end: Offset(1.05, 1.05),
          ),
    );
  }
}

// Card da loja
class ShopItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String imageAsset;
  final bool isUnlocked;
  final bool hasEnoughCoins;
  final bool isConsumable;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.imageAsset,
    required this.isUnlocked,
    required this.hasEnoughCoins,
    this.isConsumable = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isUnlocked
                ? BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: isUnlocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem do item
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Imagem com efeito de opacity se estiver bloqueado
                    Opacity(
                      opacity: isUnlocked || hasEnoughCoins ? 1.0 : 0.5,
                      child: Image.asset(imageAsset, fit: BoxFit.contain),
                    ),

                    // Badge de desbloqueado
                    if (isUnlocked)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                    // Badge de consumível
                    if (isConsumable && !isUnlocked)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.replay,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Nome do item
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              // Descrição do item
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 8),

              // Preço ou status
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Desbloqueado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_money,
                      color:
                          hasEnoughCoins
                              ? const Color(0xFFFFD747)
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cost.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            hasEnoughCoins
                                ? const Color(0xFF333333)
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Exibição de estatísticas do jogador
class StatDisplay extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatDisplay({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

// Card de nível no sumário do mundo
class WorldLevelSummaryCard extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final int stars;
  final int score;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;
  final Color color;

  const WorldLevelSummaryCard({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.stars,
    required this.score,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUnlocked ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isCompleted
                  ? color.withValues(alpha: 0.1)
                  : (isUnlocked ? Colors.white : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isCompleted
                    ? color
                    : (isUnlocked
                        ? Colors.grey.shade300
                        : Colors.grey.shade200),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Círculo com número do nível
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted
                        ? color
                        : (isUnlocked ? Colors.white : Colors.grey.shade300),
                border:
                    isCompleted
                        ? null
                        : Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: Center(
                child: Text(
                  levelNumber.toString(),
                  style: TextStyle(
                    color:
                        isCompleted
                            ? Colors.white
                            : (isUnlocked ? color : Colors.grey),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nome e pontuação
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  if (isCompleted)
                    Text(
                      'Pontuação: $score',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    )
                  else if (isUnlocked)
                    const Text(
                      'Não completado',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  else
                    const Text(
                      'Bloqueado',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),

            // Estrelas
            if (isCompleted)
              Row(
                children: List.generate(3, (index) {
                  return Icon(
                    Icons.star,
                    color:
                        index < stars
                            ? const Color(0xFFFFD747)
                            : Colors.grey.shade300,
                    size: 20,
                  );
                }),
              )
            else if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.grey, size: 20)
            else
              const Icon(
                Icons.play_circle_fill,
                color: Color(0xFF42E682),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// Dialog de recompensa
class RewardDialog extends StatelessWidget {
  final String title;
  final String message;
  final int coins;
  final bool isSpecial;
  final VoidCallback onCollect;

  const RewardDialog({
    super.key,
    required this.title,
    required this.message,
    required this.coins,
    this.isSpecial = false,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              isSpecial
                  ? const Color(0xFFFFD747)
                  : Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animação de moedas
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD747),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD747).withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '+',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSpecial ? 48 : 36,
                ),
              ),
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 16),

          // Mensagem
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 12),

          // Moedas ganhas
          Text(
            '+ $coins moedas',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF42E682),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onCollect,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSpecial
                    ? const Color(0xFFFFD747)
                    : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('COLETAR'),
        ),
      ],
    );
  }
}

// Moldura para avatar
class AvatarFrame extends StatelessWidget {
  final String avatarAsset;
  final String? frameAsset;
  final double size;
  final VoidCallback? onTap;

  const AvatarFrame({
    super.key,
    required this.avatarAsset,
    this.frameAsset,
    this.size = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow:
              frameAsset != null
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            // Avatar
            Padding(
              padding: EdgeInsets.all(frameAsset != null ? size * 0.1 : 0),
              child: CircleAvatar(
                radius: size / 2,
                backgroundImage: AssetImage(avatarAsset),
              ),
            ),

            // Moldura
            if (frameAsset != null)
              SizedBox(
                width: size,
                height: size,
                child: Image.asset(frameAsset!, fit: BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }
}

// Botão de configurações
class SettingsToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const SettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle:
          subtitle != null
              ? Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              )
              : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
