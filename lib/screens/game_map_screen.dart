import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/player_model.dart';
import '../providers/player_provider.dart';
import '../widgets/coin_display.dart';
import 'challenge_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  bool _showDailyReward = false;
  LoginReward? _dailyReward;

  @override
  void initState() {
    super.initState();
    _checkDailyReward();
  }

  // Verifica se há recompensa diária para mostrar
  Future<void> _checkDailyReward() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final reward = await playerProvider.checkDailyReward();

    if (reward != null) {
      setState(() {
        _showDailyReward = true;
        _dailyReward = reward;
      });

      // Mostra o diálogo de recompensa após um breve delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showDailyRewardDialog(reward);
        }
      });
    }
  }

  // Mostra o diálogo de recompensa diária
  void _showDailyRewardDialog(LoginReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              reward.isSpecialDay
                  ? 'Recompensa Especial!'
                  : 'Recompensa Diária!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4C6FFF),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD747),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: reward.isSpecialDay ? 48 : 36,
                      ),
                    ),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 16),

                // Dias consecutivos
                Text(
                  '${reward.daysStreak} ${reward.daysStreak == 1 ? 'Dia' : 'Dias'} Consecutivos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Moedas ganhas
                Text(
                  '+ ${reward.coinsEarned} moedas',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF42E682),
                  ),
                ),

                if (reward.isSpecialDay)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Bônus especial por completar uma semana!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF4C6FFF),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _showDailyReward = false;
                  });
                },
                child: const Text('COLETAR'),
              ),
            ],
          ),
    );
  }

  // Navega para a tela do desafio
  void _navigateToChallenge(World world, Level level) {
    if (!level.unlocked) {
      _showLevelLockedDialog();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChallengeScreen(
              worldId: world.id,
              levelId: level.id,
              operation: world.operation,
              difficulty: level.difficulty,
              challengeType: level.challengeType,
            ),
      ),
    );
  }

  // Mostra diálogo de nível bloqueado
  void _showLevelLockedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Nível Bloqueado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(
                  'Complete os níveis anteriores para desbloquear este nível.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body: SafeArea(
        child: Consumer<PlayerProvider>(
          builder: (context, playerProvider, child) {
            if (playerProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final player = playerProvider.player;
            if (player == null) {
              return const Center(
                child: Text('Erro ao carregar dados do jogador'),
              );
            }

            // Encontra o mundo atual
            final currentWorld = player.getWorld(player.currentWorld);
            if (currentWorld == null) {
              return const Center(child: Text('Erro ao carregar mundo atual'));
            }

            return Column(
              children: [
                // Barra superior com título e moedas
                _buildTopBar(player),

                // Lista de mundos para seleção
                _buildWorldSelector(player),

                // Mapa do mundo atual com níveis
                Expanded(child: _buildWorldMap(currentWorld, player)),

                // Barra de navegação inferior
                _buildBottomNavigationBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  // Constrói a barra superior
  Widget _buildTopBar(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Avatar do jogador
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(
              'assets/avatars/${player.avatarId}.png',
            ),
          ),
          const SizedBox(width: 12),

          // Nome do jogador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Nível ${player.currentWorld}-${player.currentLevel}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Moedas do jogador
          CoinDisplay(coins: player.coins, showAnimation: _showDailyReward),
        ],
      ),
    );
  }

  // Constrói o seletor de mundos
  Widget _buildWorldSelector(Player player) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: player.worlds.length,
        itemBuilder: (context, index) {
          final world = player.worlds[index];
          final isCurrentWorld = world.id == player.currentWorld;
          final isUnlocked = world.unlocked;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap:
                  isUnlocked
                      ? () {
                        final playerProvider = Provider.of<PlayerProvider>(
                          context,
                          listen: false,
                        );

                        // Atualiza o mundo atual no provider
                        playerProvider.setCurrentWorld(world.id);
                      }
                      : null,
              child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color:
                          isUnlocked
                              ? (isCurrentWorld
                                  ? HexColor.fromHex(world.themeColor)
                                  : Colors.white)
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          isCurrentWorld
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                      boxShadow:
                          isCurrentWorld
                              ? [
                                BoxShadow(
                                  color: HexColor.fromHex(
                                    world.themeColor,
                                  ).withValues(alpha: 0.5),
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
                        // Ícone/Imagem do mundo
                        Icon(
                          _getWorldIcon(world.operation),
                          color:
                              isUnlocked
                                  ? (isCurrentWorld
                                      ? Colors.white
                                      : HexColor.fromHex(world.themeColor))
                                  : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 4),

                        // Nome do mundo
                        Text(
                          world.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                isUnlocked
                                    ? (isCurrentWorld
                                        ? Colors.white
                                        : Colors.black87)
                                    : Colors.grey,
                            fontWeight:
                                isCurrentWorld
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(target: isCurrentWorld ? 1 : 0)
                  .scale(
                    duration: const Duration(milliseconds: 300),
                    begin: Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                  ),
            ),
          );
        },
      ),
    );
  }

  // Obtém o ícone para o tipo de operação do mundo
  IconData _getWorldIcon(String operation) {
    switch (operation) {
      case 'sequence':
        return Icons.format_list_numbered;
      case 'addition':
        return Icons.add;
      case 'subtraction':
        return Icons.remove;
      case 'multiplication':
        return Icons.close;
      case 'division':
        return Icons.functions;
      case 'fractions':
        return Icons.pie_chart;
      default:
        return Icons.calculate;
    }
  }

  // Constrói o mapa do mundo com os níveis
  Widget _buildWorldMap(World currentWorld, Player player) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Caminho entre níveis
          CustomPaint(
            size: Size.infinite,
            painter: LevelPathPainter(
              world: currentWorld,
              themeColor: HexColor.fromHex(currentWorld.themeColor),
            ),
          ),

          // Os níveis do mundo
          ...currentWorld.levels.map((level) {
            // Calcula a posição no mapa baseado no ID do nível
            // Isso é uma simplificação - você pode personalizar conforme necessário
            final levelPosition = _calculateLevelPosition(
              level.id,
              currentWorld.levels.length,
            );

            return Positioned(
              left: levelPosition.dx,
              top: levelPosition.dy,
              child: GestureDetector(
                onTap: () => _navigateToChallenge(currentWorld, level),
                child: _buildLevelItem(level, currentWorld, player),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Calcula a posição do nível no mapa
  Offset _calculateLevelPosition(int levelId, int totalLevels) {
    // Esta é uma implementação simples que distribui os níveis em um caminho em S
    // Você pode personalizar isso conforme sua necessidade

    final width =
        MediaQuery.of(context).size.width -
        32; // Largura disponível menos margens
    final height =
        MediaQuery.of(context).size.height * 0.5; // Altura aproximada

    // Normaliza a posição do nível (0.0 a 1.0)
    final normalizedPos = (levelId - 1) / (totalLevels - 1);

    // Para criar um caminho em S, alternamos a direção a cada metade
    if (normalizedPos < 0.5) {
      // Primeira metade: da esquerda para a direita
      final x = width * (normalizedPos * 2) * 0.8 + width * 0.1;
      final y = height * 0.3;
      return Offset(x, y);
    } else {
      // Segunda metade: da direita para a esquerda
      final x = width * (1 - (normalizedPos - 0.5) * 2) * 0.8 + width * 0.1;
      final y = height * 0.7;
      return Offset(x, y);
    }
  }

  // Constrói um item de nível
  Widget _buildLevelItem(Level level, World world, Player player) {
    final isCurrentLevel =
        level.id == player.currentLevel && world.id == player.currentWorld;
    final isCompleted = level.completed;
    final isUnlocked = level.unlocked;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted
                ? HexColor.fromHex(world.themeColor)
                : (isUnlocked ? Colors.white : Colors.grey.shade300),
        border: Border.all(
          color:
              isCurrentLevel
                  ? HexColor.fromHex(world.themeColor)
                  : (isCompleted ? Colors.white : Colors.grey.shade400),
          width: isCurrentLevel ? 3 : 1,
        ),
        boxShadow:
            isCurrentLevel || isCompleted
                ? [
                  BoxShadow(
                    color: HexColor.fromHex(
                      world.themeColor,
                    ).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Número do nível
            Text(
              level.id.toString(),
              style: TextStyle(
                color:
                    isCompleted
                        ? Colors.white
                        : (isUnlocked
                            ? HexColor.fromHex(world.themeColor)
                            : Colors.grey),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            // Ícone de bloqueado se não estiver desbloqueado
            if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.grey, size: 20),

            // Ícone de completo se estiver completo
            if (isCompleted)
              const Positioned(
                bottom: 5,
                right: 5,
                child: Icon(Icons.check_circle, color: Colors.white, size: 16),
              ),

            // Estrelas do nível, se tiver
            if (level.stars > 0 && !isCurrentLevel)
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    return Icon(
                      Icons.star,
                      color:
                          index < level.stars
                              ? const Color(0xFFFFD747)
                              : Colors.grey.shade300,
                      size: 10,
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Constrói a barra de navegação inferior
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.person,
            label: 'Perfil',
            color: Theme.of(context).primaryColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildNavButton(
            icon: Icons.shopping_cart,
            label: 'Loja',
            color: const Color(0xFF42E682),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ShopScreen()),
              );
            },
          ),
          _buildNavButton(
            icon: Icons.emoji_events,
            label: 'Prêmios',
            color: const Color(0xFFFFD747),
            onTap: () {
              //  Navigator.of(context).push(
              //MaterialPageRoute(
              // builder: (context) => const AchievementsScreen(),
              // ),
              // );
            },
          ),
          _buildNavButton(
            icon: Icons.settings,
            label: 'Config',
            color: Colors.grey.shade400,
            onTap: () {
              // Navigator.of(context).push(
              //MaterialPageRoute(builder: (context) => const SettingsScreen()),
              //   );
            },
          ),
        ],
      ),
    );
  }

  // Constrói um botão da barra de navegação
  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter para desenhar o caminho entre níveis
class LevelPathPainter extends CustomPainter {
  final World world;
  final Color themeColor;

  LevelPathPainter({required this.world, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = themeColor.withValues(alpha: 0.3)
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Simplificação: caminho em S
    final width = size.width;
    final height = size.height;

    path.moveTo(width * 0.1, height * 0.3);
    path.lineTo(width * 0.9, height * 0.3);
    path.lineTo(width * 0.9, height * 0.5);
    path.lineTo(width * 0.1, height * 0.5);
    path.lineTo(width * 0.1, height * 0.7);
    path.lineTo(width * 0.9, height * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extensão para converter string hex para Color
extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// Classe LoginReward (necessária para a tela)
class LoginReward {
  final int daysStreak;
  final int coinsEarned;
  final bool isSpecialDay;

  LoginReward({
    required this.daysStreak,
    required this.coinsEarned,
    required this.isSpecialDay,
  });
}

// Extensão para o PlayerProvider
extension PlayerProviderExtension on PlayerProvider {
  Future<LoginReward?> checkDailyReward() async {
    // Implemente aqui a lógica para verificar a recompensa diária
    // Esta é uma simplificação para o exemplo
    await Future.delayed(const Duration(milliseconds: 300));

    if (player != null) {
      // Verifica se é um novo dia desde o último login
      final now = DateTime.now();
      final lastLogin = player!.lastPlayDate;

      if (lastLogin.year != now.year ||
          lastLogin.month != now.month ||
          lastLogin.day != now.day) {
        // Atualiza o streak de login no player
        final consecutiveDays = player!.consecutiveDays + 1;

        // Define a recompensa com base na sequência de dias
        final coins = _calculateDailyReward(consecutiveDays);

        // Atualiza o player
        player!.lastPlayDate = now;
        player!.consecutiveDays = consecutiveDays;
        player!.addCoins(coins);

        // Salva o player atualizado
        await refreshPlayerData();

        return LoginReward(
          daysStreak: consecutiveDays,
          coinsEarned: coins,
          isSpecialDay: consecutiveDays % 7 == 0, // A cada 7 dias é especial
        );
      }
    }

    return null;
  }

  int _calculateDailyReward(int consecutiveDays) {
    // Base: 10 moedas
    int coins = 10;

    // Bônus por sequência
    if (consecutiveDays >= 30) {
      coins = 50; // Um mês!
    } else if (consecutiveDays >= 14) {
      coins = 30; // Duas semanas
    } else if (consecutiveDays >= 7) {
      coins = 20; // Uma semana
    } else if (consecutiveDays >= 3) {
      coins = 15; // Alguns dias
    }

    // Bônus especial a cada 7 dias (multiplicador)
    if (consecutiveDays % 7 == 0) {
      coins *= 2;
    }

    return coins;
  }

  Future<void> setCurrentWorld(int worldId) async {
    if (player == null) return;

    final world = player!.getWorld(worldId);
    if (world == null || !world.unlocked) return;

    player!.currentWorld = worldId;

    // Se não tiver nível atual definido no mundo, define o primeiro
    final hasCurrentLevelInWorld = world.levels.any(
      (level) => level.id == player!.currentLevel && level.unlocked,
    );

    if (!hasCurrentLevelInWorld) {
      // Encontra o primeiro nível desbloqueado
      final firstUnlockedLevel = world.levels.firstWhere(
        (level) => level.unlocked,
        orElse: () => world.levels.first,
      );

      player!.currentLevel = firstUnlockedLevel.id;
    }

    // Salva as alterações
    await refreshPlayerData();
  }
}
