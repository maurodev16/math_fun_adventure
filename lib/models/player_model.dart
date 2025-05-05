import 'package:hive_flutter/hive_flutter.dart';

part 'player_model.g.dart';

// Execute o comando abaixo para gerar código do Hive:
// flutter packages pub run build_runner build

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String avatarId;

  @HiveField(2)
  int coins;

  @HiveField(3)
  List<World> worlds;

  @HiveField(4)
  List<String> unlockedItems;

  @HiveField(5)
  int totalScore;

  @HiveField(6)
  int currentLevel;

  @HiveField(7)
  int currentWorld;

  @HiveField(8)
  List<Achievement> achievements;

  @HiveField(9)
  int playTimeSecs;

  @HiveField(10)
  DateTime lastPlayDate;

  @HiveField(11)
  int consecutiveDays;

  Player({
    required this.name,
    required this.avatarId,
    this.coins = 0,
    this.worlds = const [],
    this.unlockedItems = const [],
    this.totalScore = 0,
    this.currentLevel = 1,
    this.currentWorld = 1,
    this.achievements = const [],
    this.playTimeSecs = 0,
    required this.lastPlayDate,
    this.consecutiveDays = 1,
  });

  // Métodos para gerenciar progresso
  bool isLevelUnlocked(int worldId, int levelId) {
    final world = getWorld(worldId);
    if (world == null) return false;

    final level = world.getLevel(levelId);
    return level?.unlocked ?? false;
  }

  World? getWorld(int worldId) {
    try {
      return worlds.firstWhere((world) => world.id == worldId);
    } catch (e) {
      return null;
    }
  }

  bool unlockNextLevel() {
    final currentWorldObj = getWorld(currentWorld);
    if (currentWorldObj == null) return false;

    // Tenta desbloquear o próximo nível do mundo atual
    if (currentLevel < currentWorldObj.levels.length) {
      final nextLevel = currentLevel + 1;
      final levelIndex = currentWorldObj.levels.indexWhere(
        (level) => level.id == nextLevel,
      );

      if (levelIndex != -1) {
        currentWorldObj.levels[levelIndex].unlocked = true;
        currentLevel = nextLevel;
        return true;
      }
    }
    // Se não houver mais níveis no mundo atual, tenta desbloquear o próximo mundo
    else if (currentWorld < worlds.length) {
      final nextWorld = currentWorld + 1;
      final worldIndex = worlds.indexWhere((world) => world.id == nextWorld);

      if (worldIndex != -1) {
        worlds[worldIndex].unlocked = true;
        // Define o primeiro nível do novo mundo como atual
        if (worlds[worldIndex].levels.isNotEmpty) {
          currentWorld = nextWorld;
          currentLevel = worlds[worldIndex].levels.first.id;
          return true;
        }
      }
    }

    return false;
  }

  void addCoins(int amount) {
    coins += amount;
  }

  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      return true;
    }
    return false;
  }

  void addScore(int points) {
    totalScore += points;
  }

  void unlockItem(String itemId) {
    if (!unlockedItems.contains(itemId)) {
      unlockedItems.add(itemId);
    }
  }

  bool hasItem(String itemId) {
    return unlockedItems.contains(itemId);
  }

  void addPlayTime(int seconds) {
    playTimeSecs += seconds;
  }

  void updateLoginStreak() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Verifica se o último login foi ontem
    if (lastPlayDate.year == yesterday.year &&
        lastPlayDate.month == yesterday.month &&
        lastPlayDate.day == yesterday.day) {
      consecutiveDays++;
    }
    // Se não foi ontem, mas também não foi hoje, reseta a sequência
    else if (lastPlayDate.year != now.year ||
        lastPlayDate.month != now.month ||
        lastPlayDate.day != now.day) {
      consecutiveDays = 1;
    }

    lastPlayDate = now;
  }

  // Conquistas
  void checkAndGrantAchievements() {
    // Verifica conquistas de pontuação
    if (totalScore >= 1000 && !hasAchievement('score_1000')) {
      addAchievement(
        Achievement(
          id: 'score_1000',
          title: '1000 Pontos',
          description: 'Acumule 1000 pontos no jogo',
          iconId: 'achievement_score',
          dateUnlocked: DateTime.now(),
          rewardCoins: 50,
        ),
      );
    }

    // Verifica conquistas de sequência de dias
    if (consecutiveDays >= 7 && !hasAchievement('streak_7')) {
      addAchievement(
        Achievement(
          id: 'streak_7',
          title: 'Uma Semana Estudando',
          description: 'Jogue por 7 dias consecutivos',
          iconId: 'achievement_streak',
          dateUnlocked: DateTime.now(),
          rewardCoins: 100,
        ),
      );
    }

    // Verifica conquistas de níveis completados
    int totalCompletedLevels = 0;
    for (final world in worlds) {
      for (final level in world.levels) {
        if (level.completed) totalCompletedLevels++;
      }
    }

    if (totalCompletedLevels >= 10 && !hasAchievement('complete_10')) {
      addAchievement(
        Achievement(
          id: 'complete_10',
          title: 'Explorando a Matemática',
          description: 'Complete 10 níveis',
          iconId: 'achievement_levels',
          dateUnlocked: DateTime.now(),
          rewardCoins: 75,
        ),
      );
    }
  }

  bool hasAchievement(String achievementId) {
    return achievements.any((achievement) => achievement.id == achievementId);
  }

  void addAchievement(Achievement achievement) {
    if (!hasAchievement(achievement.id)) {
      achievements.add(achievement);
      addCoins(achievement.rewardCoins);
    }
  }
}

@HiveType(typeId: 1)
class World extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconId;

  @HiveField(4)
  List<Level> levels;

  @HiveField(5)
  bool unlocked;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  String themeColor;

  @HiveField(8)
  String operation; // "addition", "subtraction", etc.

  World({
    required this.id,
    required this.name,
    required this.description,
    required this.iconId,
    required this.levels,
    this.unlocked = false,
    this.completed = false,
    required this.themeColor,
    required this.operation,
  });

  Level? getLevel(int levelId) {
    try {
      return levels.firstWhere((level) => level.id == levelId);
    } catch (e) {
      return null;
    }
  }

  bool isCompleted() {
    return levels.every((level) => level.completed);
  }

  void updateCompletionStatus() {
    completed = isCompleted();
  }

  int totalStars() {
    return levels.fold(0, (sum, level) => sum + level.stars);
  }
}

@HiveType(typeId: 2)
class Level extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int difficulty; // 1-5

  @HiveField(3)
  bool unlocked;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  int stars; // 0-3

  @HiveField(6)
  int highScore;

  @HiveField(7)
  int bestTime; // em segundos

  @HiveField(8)
  String challengeType; // "sequence", "operation", etc.

  @HiveField(9)
  DateTime? lastPlayedDate;

  Level({
    required this.id,
    required this.name,
    required this.difficulty,
    this.unlocked = false,
    this.completed = false,
    this.stars = 0,
    this.highScore = 0,
    this.bestTime = 0,
    required this.challengeType,
    this.lastPlayedDate,
  });

  void completeLevel(int score, int newStars, int timeInSeconds) {
    completed = true;

    // Atualiza apenas se a pontuação for melhor
    if (score > highScore) {
      highScore = score;
    }

    // Atualiza apenas se as estrelas forem mais
    if (newStars > stars) {
      stars = newStars;
    }

    // Atualiza o melhor tempo se for menor que o anterior (e não for zero)
    if (timeInSeconds > 0 && (bestTime == 0 || timeInSeconds < bestTime)) {
      bestTime = timeInSeconds;
    }

    lastPlayedDate = DateTime.now();
  }
}

@HiveType(typeId: 3)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconId;

  @HiveField(4)
  DateTime dateUnlocked;

  @HiveField(5)
  int rewardCoins;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconId,
    required this.dateUnlocked,
    required this.rewardCoins,
  });
}

// Classe para gerenciar a inicialização de dados
class GameDataInitializer {
  static Player createNewPlayer(String name, String avatarId) {
    final List<World> worlds = _createInitialWorlds();

    return Player(
      name: name,
      avatarId: avatarId,
      worlds: worlds,
      coins: 100, // Moedas iniciais
      lastPlayDate: DateTime.now(),
      currentWorld: 1,
      currentLevel: 1,
    );
  }

  static List<World> _createInitialWorlds() {
    return [
      // Mundo 1: Ilha dos Números (6-7 anos)
      World(
        id: 1,
        name: 'Ilha dos Números',
        description: 'Aprenda a reconhecer e ordenar números',
        iconId: 'world_numbers',
        themeColor: '#42E682', // Verde
        operation: 'sequence',
        unlocked: true, // Primeiro mundo começa desbloqueado
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Praia dos Números',
            difficulty: 1,
            challengeType: 'sequence',
            unlocked: true, // Primeiro nível começa desbloqueado
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Floresta Numérica',
            difficulty: 1,
            challengeType: 'sequence',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Ponte da Contagem',
            difficulty: 2,
            challengeType: 'sequence',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Cachoeira da Ordem',
            difficulty: 2,
            challengeType: 'sequence',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Vulcão Numérico',
            difficulty: 3,
            challengeType: 'sequence',
          ),
        ],
      ),

      // Mundo 2: Floresta da Adição (7-8 anos)
      World(
        id: 2,
        name: 'Floresta da Adição',
        description: 'Aprenda a somar números',
        iconId: 'world_addition',
        themeColor: '#4C6FFF', // Azul
        operation: 'addition',
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Clareira da Soma',
            difficulty: 1,
            challengeType: 'operation',
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Trilha dos Números',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Rio da Adição',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Caverna da Dezena',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Árvore da Soma',
            difficulty: 3,
            challengeType: 'operation',
          ),
        ],
      ),

      // Mundo 3: Caverna da Subtração (8-9 anos)
      World(
        id: 3,
        name: 'Caverna da Subtração',
        description: 'Aprenda a subtrair números',
        iconId: 'world_subtraction',
        themeColor: '#9D71EA', // Roxo
        operation: 'subtraction',
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Entrada da Caverna',
            difficulty: 1,
            challengeType: 'operation',
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Galeria de Cristais',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Lago Subterrâneo',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Abismo da Subtração',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Tesouro Escondido',
            difficulty: 3,
            challengeType: 'operation',
          ),
        ],
      ),

      // Mundo 4: Castelo da Multiplicação (9-10 anos)
      World(
        id: 4,
        name: 'Castelo da Multiplicação',
        description: 'Aprenda a multiplicar números',
        iconId: 'world_multiplication',
        themeColor: '#FFD747', // Amarelo
        operation: 'multiplication',
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Portão do Castelo',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Sala do Trono',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Torre da Tabuada',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Biblioteca Real',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Sala do Tesouro',
            difficulty: 4,
            challengeType: 'operation',
          ),
        ],
      ),

      // Mundo 5: Oceano da Divisão (10-11 anos)
      World(
        id: 5,
        name: 'Oceano da Divisão',
        description: 'Aprenda a dividir números',
        iconId: 'world_division',
        themeColor: '#FF6B6B', // Vermelho
        operation: 'division',
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Praia da Divisão',
            difficulty: 2,
            challengeType: 'operation',
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Recife de Coral',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Navio Afundado',
            difficulty: 3,
            challengeType: 'operation',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Caverna Submarina',
            difficulty: 4,
            challengeType: 'operation',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Cidade Perdida',
            difficulty: 4,
            challengeType: 'operation',
          ),
        ],
      ),

      // Mundo 6: Laboratório das Frações (11-12 anos)
      World(
        id: 6,
        name: 'Laboratório das Frações',
        description: 'Aprenda sobre frações',
        iconId: 'world_fractions',
        themeColor: '#00BCD4', // Ciano
        operation: 'fractions',
        levels: [
          // Nível 1
          Level(
            id: 1,
            name: 'Sala de Experimentos',
            difficulty: 3,
            challengeType: 'fractions',
          ),
          // Nível 2
          Level(
            id: 2,
            name: 'Estufa das Frações',
            difficulty: 3,
            challengeType: 'fractions',
          ),
          // Nível 3
          Level(
            id: 3,
            name: 'Sala de Mistura',
            difficulty: 4,
            challengeType: 'fractions',
          ),
          // Nível 4
          Level(
            id: 4,
            name: 'Observatório Fracionário',
            difficulty: 4,
            challengeType: 'fractions',
          ),
          // Nível 5
          Level(
            id: 5,
            name: 'Máquina do Tempo',
            difficulty: 5,
            challengeType: 'fractions',
          ),
        ],
      ),
    ];
  }
}
