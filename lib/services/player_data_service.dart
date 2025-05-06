import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/player_model.dart';
import '../models/game_challenge_models.dart';
import '../screens/game_map_screen.dart'; // Add this import

class PlayerDataService {
  static const String _playerBoxName = 'playerBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _playerKey = 'currentPlayer';
  static const String _gameDataBoxName = 'gameDataBox'; // Add this

  // Inicialização do Hive
  static Future<void> initialize() async {
    // Inicializa o Hive
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Registra os adaptadores para as classes do modelo
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(WorldAdapter());
    Hive.registerAdapter(LevelAdapter());
    Hive.registerAdapter(AchievementAdapter());

    // Register game challenge adapters
    Hive.registerAdapter(ProblemTypeAdapter());
    Hive.registerAdapter(ProblemAdapter());
    Hive.registerAdapter(DraggableItemAdapter());
    Hive.registerAdapter(TargetSlotAdapter());

    // Abre as boxes que usaremos
    await Hive.openBox<Player>(_playerBoxName);
    await Hive.openBox(_settingsBoxName);
    await Hive.openBox(_gameDataBoxName); // Add this line

    debugPrint('PlayerDataService: Hive inicializado com sucesso');
  }

  // Salva o jogador atual
  static Future<void> savePlayer(Player player) async {
    final box = Hive.box<Player>(_playerBoxName);
    await box.put(_playerKey, player);
    debugPrint('PlayerDataService: Jogador salvo com sucesso');
  }

  // Carrega o jogador atual
  static Player? loadPlayer() {
    final box = Hive.box<Player>(_playerBoxName);
    final player = box.get(_playerKey);
    debugPrint(
      'PlayerDataService: Jogador carregado: ${player?.name ?? "Nenhum"}',
    );
    return player;
  }

  // Cria um novo jogador (e salva)
  static Future<Player> createNewPlayer(String name, String avatarId) async {
    final player = GameDataInitializer.createNewPlayer(name, avatarId);
    await savePlayer(player);
    return player;
  }

  // Verifica se existe um jogador salvo
  static bool hasExistingPlayer() {
    final box = Hive.box<Player>(_playerBoxName);
    return box.containsKey(_playerKey);
  }

  // Reseta todos os dados (para testes ou quando o usuário quiser recomeçar)
  static Future<void> resetAllData() async {
    final playerBox = Hive.box<Player>(_playerBoxName);
    final settingsBox = Hive.box(_settingsBoxName);
    final gameDataBox = Hive.box(_gameDataBoxName); // Add this

    await playerBox.clear();
    await settingsBox.clear();
    await gameDataBox.clear(); // Add this

    debugPrint('PlayerDataService: Todos os dados foram resetados');
  }

  // Salva uma configuração específica
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(key, value);
  }

  // Carrega uma configuração
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    final box = Hive.box(_settingsBoxName);
    return box.get(key, defaultValue: defaultValue);
  }

  // Methods for game challenge data
  static Future<void> saveGameData(String key, dynamic value) async {
    final box = Hive.box(_gameDataBoxName);
    await box.put(key, value);
  }

  static dynamic getGameData(String key, {dynamic defaultValue}) {
    final box = Hive.box(_gameDataBoxName);
    return box.get(key, defaultValue: defaultValue);
  }

  // Atualiza o progresso após completar um nível
  static Future<void> updateLevelProgress({
    required int worldId,
    required int levelId,
    required int score,
    required int stars,
    required int timeInSeconds,
  }) async {
    final player = loadPlayer();
    if (player == null) return;

    final world = player.getWorld(worldId);
    if (world == null) return;

    final level = world.getLevel(levelId);
    if (level == null) return;

    // Atualiza o nível
    level.completeLevel(score, stars, timeInSeconds);

    // Verifica se todos os níveis do mundo foram completados
    world.updateCompletionStatus();

    // Desbloqueia o próximo nível, se necessário
    if (level.id == player.currentLevel && level.completed) {
      player.unlockNextLevel();
    }

    // Adiciona pontuação ao jogador
    player.addScore(score);

    // Adiciona moedas baseado nas estrelas
    final coinsEarned = stars * 25; // 25 moedas por estrela
    player.addCoins(coinsEarned);

    // Verifica e concede conquistas
    player.checkAndGrantAchievements();

    // Salva o jogador
    await savePlayer(player);

    debugPrint(
      'PlayerDataService: Progresso do nível atualizado - Mundo: $worldId, Nível: $levelId, Estrelas: $stars',
    );
  }

  // Atualiza o status de login diário
  static Future<LoginReward?> checkDailyLogin() async {
    final player = loadPlayer();
    if (player == null) return null;

    final now = DateTime.now();
    final lastLogin = player.lastPlayDate;

    // Verifica se é um novo dia em relação ao último login
    if (lastLogin.year != now.year ||
        lastLogin.month != now.month ||
        lastLogin.day != now.day) {
      player.updateLoginStreak();

      // Define a recompensa com base na sequência de dias
      final coins = _calculateDailyReward(player.consecutiveDays);
      player.addCoins(coins);

      await savePlayer(player);

      return LoginReward(
        daysStreak: player.consecutiveDays,
        coinsEarned: coins,
        isSpecialDay:
            player.consecutiveDays % 7 == 0, // A cada 7 dias é especial
      );
    }

    return null;
  }

  // Calcula a recompensa diária com base na sequência
  static int _calculateDailyReward(int consecutiveDays) {
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

  // Compra um item da loja
  static Future<bool> purchaseItem(String itemId, int cost) async {
    final player = loadPlayer();
    if (player == null) return false;

    // Verifica se já tem o item
    if (player.hasItem(itemId)) {
      return true; // Já possui o item
    }

    // Tenta gastar as moedas
    if (player.spendCoins(cost)) {
      player.unlockItem(itemId);
      await savePlayer(player);
      return true;
    }

    return false; // Moedas insuficientes
  }

  // Estatísticas de uso para analytics
  static Future<void> trackGameSession(int playTimeSecs) async {
    final player = loadPlayer();
    if (player == null) return;

    player.addPlayTime(playTimeSecs);
    await savePlayer(player);
  }

  // Exporta dados para backup (retorna um Map que pode ser convertido para JSON)
  static Map<String, dynamic> exportPlayerData() {
    final player = loadPlayer();
    if (player == null) return {};

    // Cria um mapa com os dados relevantes
    // Nota: Uma implementação real faria uma conversão completa de todas as propriedades
    return {
      'name': player.name,
      'avatarId': player.avatarId,
      'coins': player.coins,
      'totalScore': player.totalScore,
      'currentLevel': player.currentLevel,
      'currentWorld': player.currentWorld,
      'playTimeSecs': player.playTimeSecs,
      'lastPlayDate': player.lastPlayDate.toIso8601String(),
      'consecutiveDays': player.consecutiveDays,
      'unlockedItems': player.unlockedItems,
      'achievements':
          player.achievements
              .map(
                (a) => {
                  'id': a.id,
                  'title': a.title,
                  'dateUnlocked': a.dateUnlocked.toIso8601String(),
                },
              )
              .toList(),
      'worlds':
          player.worlds
              .map(
                (w) => {
                  'id': w.id,
                  'name': w.name,
                  'unlocked': w.unlocked,
                  'completed': w.completed,
                  'totalStars': w.totalStars(),
                  'levels':
                      w.levels
                          .map(
                            (l) => {
                              'id': l.id,
                              'stars': l.stars,
                              'completed': l.completed,
                              'highScore': l.highScore,
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
    };
  }

  // Importa dados de backup
  static Future<bool> importPlayerData(Map<String, dynamic> data) async {
    try {
      // Implementação simplificada - uma versão real faria validação completa dos dados
      final player = loadPlayer();
      if (player == null) return false;

      player.name = data['name'] ?? player.name;
      player.coins = data['coins'] ?? player.coins;
      player.totalScore = data['totalScore'] ?? player.totalScore;

      await savePlayer(player);
      return true;
    } catch (e) {
      debugPrint('PlayerDataService: Erro ao importar dados - $e');
      return false;
    }
  }
}
