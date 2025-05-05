import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/player_model.dart';
import '../providers/player_provider.dart';
import '../widgets/shared_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PlayerProvider>(
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

          return Column(
            children: [
              // Cabeçalho do perfil
              _buildProfileHeader(player),

              // Abas de estatísticas, mundos e conquistas
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Estatísticas'),
                  Tab(text: 'Mundos'),
                  Tab(text: 'Conquistas'),
                ],
              ),

              // Conteúdo das abas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatsTab(player),
                    _buildWorldsTab(player),
                    _buildAchievementsTab(player),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Constrói o cabeçalho do perfil com avatar e informações básicas
  Widget _buildProfileHeader(Player player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Avatar com moldura
          Stack(
            children: [
              AvatarFrame(
                avatarAsset: 'assets/avatars/${player.avatarId}.png',
                frameAsset:
                    player.hasItem('frame_gold')
                        ? 'assets/shop/frame_gold.png'
                        : (player.hasItem('frame_silver')
                            ? 'assets/shop/frame_silver.png'
                            : (player.hasItem('frame_bronze')
                                ? 'assets/shop/frame_bronze.png'
                                : null)),
                size: 90,
                onTap: () {
                  // Navegação para a tela de edição de perfil
                },
              ),

              // Emblema indicando o nível
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        'Nível ${player.currentWorld}-${player.currentLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Informações do jogador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do jogador
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Dias consecutivos
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFFFFD747),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.consecutiveDays} ${player.consecutiveDays == 1 ? 'dia' : 'dias'} consecutivos',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Moedas
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Color(0xFFFFD747),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.coins} moedas',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Botão de editar perfil
                SizedBox(
                  height: 30,
                  child: GameButton(
                    text: 'Editar Perfil',
                    onTap: () {
                      // Navegação para a tela de edição de perfil
                    },
                    icon: Icons.edit,
                    isOutlined: true,
                    isLarge: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Constrói a aba de estatísticas
  Widget _buildStatsTab(Player player) {
    final formatter = NumberFormat('#,###');

    // Calcula estatísticas adicionais
    int totalLevelsCompleted = 0;
    int totalStars = 0;

    for (final world in player.worlds) {
      for (final level in world.levels) {
        if (level.completed) {
          totalLevelsCompleted++;
          totalStars += level.stars;
        }
      }
    }

    final completionRate =
        player.worlds.isEmpty
            ? 0.0
            : totalLevelsCompleted /
                player.worlds.fold(
                  0,
                  (sum, world) => sum + world.levels.length,
                );

    // Calcula o tempo de jogo formatado
    final hours = player.playTimeSecs ~/ 3600;
    final minutes = (player.playTimeSecs % 3600) ~/ 60;
    final timePlayedFormatted =
        hours > 0 ? '$hours h ${minutes}min' : '$minutes min';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Estatísticas principais
          const Text(
            'Estatísticas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Grid de estatísticas
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Pontuação total
              StatDisplay(
                label: 'Pontuação Total',
                value: formatter.format(player.totalScore),
                icon: Icons.stars,
                color: const Color(0xFFFFD747),
              ),

              // Níveis completados
              StatDisplay(
                label: 'Níveis Completados',
                value: '$totalLevelsCompleted',
                icon: Icons.check_circle,
                color: const Color(0xFF42E682),
              ),

              // Estrelas coletadas
              StatDisplay(
                label: 'Estrelas Coletadas',
                value: '$totalStars',
                icon: Icons.star,
                color: const Color(0xFFFFD747),
              ),

              // Tempo jogado
              StatDisplay(
                label: 'Tempo Jogado',
                value: timePlayedFormatted,
                icon: Icons.timer,
                color: const Color(0xFF4C6FFF),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Barra de progresso de conclusão
          const Text(
            'Progresso Geral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          AnimatedProgressBar(
            progress: completionRate,
            color: Theme.of(context).primaryColor,
            height: 12,
            showPercentage: true,
          ),

          const SizedBox(height: 24),

          // Mundos e progresso
          const Text(
            'Progresso por Mundo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Lista de progresso por mundo
          ...player.worlds.map((world) {
            // Calcula o progresso do mundo
            final completedLevels =
                world.levels.where((level) => level.completed).length;
            final totalLevels = world.levels.length;
            final progress =
                totalLevels > 0 ? completedLevels / totalLevels : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do mundo e progresso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        world.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$completedLevels/$totalLevels',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Barra de progresso do mundo
                  AnimatedProgressBar(
                    progress: progress,
                    color: Theme.of(context).primaryColor,
                    height: 8,
                    showPercentage: true,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Constrói a aba de mundos
  Widget _buildWorldsTab(Player player) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: player.worlds.length,
      itemBuilder: (context, index) {
        final world = player.worlds[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.public, color: Theme.of(context).primaryColor),
            title: Text(world.name),
            subtitle: Text(
              '${world.levels.where((l) => l.completed).length}/${world.levels.length} níveis completados',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navegar para detalhes do mundo
            },
          ),
        );
      },
    );
  }

  // Constrói a aba de conquistas
  Widget _buildAchievementsTab(Player player) {
    final achievements = player.achievements;

    if (achievements.isEmpty) {
      return const Center(child: Text('Nenhuma conquista desbloqueada ainda.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final achievement = achievements[index];

        return ListTile(
          leading: Icon(
            Icons.emoji_events,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(achievement.title),
          subtitle: Text(achievement.description),
          trailing:
              achievement.isInBox
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.lock, color: Colors.grey),
        );
      },
    );
  }
}
