import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/player_model.dart';

class PlayerDataService {
  static const String _playerBoxName = 'playerBox';
  static const String _settingsBoxName = 'settingsBox';
  static const String _playerKey = 'currentPlayer';

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

    // Abre as boxes que usaremos
    await Hive.openBox<Player>(_playerBoxName);
    await Hive.openBox(_settingsBoxName);

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

    await playerBox.clear();
    await settingsBox.clear();

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

// Classe para representar a recompensa de login diário
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

// Assuming your model classes are in player_model.dart
// Make sure to adjust the import path if needed

// Player Adapter
class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0; // Each adapter needs a unique typeId (0-255)

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return Player(
        name: fields[0] as String,
        avatarId: fields[1] as String,
        lastPlayDate: fields[7] as DateTime? ?? DateTime.now(),
      )
      ..coins = fields[2] as int
      ..totalScore = fields[3] as int
      ..currentLevel = fields[4] as int
      ..currentWorld = fields[5] as int
      ..playTimeSecs = fields[6] as int
      ..lastPlayDate = fields[7] as DateTime
      ..consecutiveDays = fields[8] as int
      ..unlockedItems = (fields[9] as List).cast<String>()
      ..achievements = (fields[10] as List).cast<Achievement>()
      ..worlds = (fields[11] as List).cast<World>();
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer.writeByte(12);
    writer.writeByte(0);
    writer.write(obj.name);
    writer.writeByte(1);
    writer.write(obj.avatarId);
    writer.writeByte(2);
    writer.write(obj.coins);
    writer.writeByte(3);
    writer.write(obj.totalScore);
    writer.writeByte(4);
    writer.write(obj.currentLevel);
    writer.writeByte(5);
    writer.write(obj.currentWorld);
    writer.writeByte(6);
    writer.write(obj.playTimeSecs);
    writer.writeByte(7);
    writer.write(obj.lastPlayDate);
    writer.writeByte(8);
    writer.write(obj.consecutiveDays);
    writer.writeByte(9);
    writer.write(obj.unlockedItems);
    writer.writeByte(10);
    writer.write(obj.achievements);
    writer.writeByte(11);
    writer.write(obj.worlds);
  }
}

// World Adapter
class WorldAdapter extends TypeAdapter<World> {
  @override
  final int typeId = 1;

  @override
  World read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return World(
        id: fields[0] as int,
        name: fields[1] as String,
        description: fields[2] as String,
        iconId: fields[3] as String,
        levels: (fields[4] as List).cast<Level>(),
        themeColor: fields[5]! as String,
        operation: fields[6] as String,
      )
      ..unlocked = fields[2] as bool
      ..completed = fields[3] as bool
      ..levels = (fields[4] as List).cast<Level>();
  }

  @override
  void write(BinaryWriter writer, World obj) {
    writer.writeByte(5);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.unlocked);
    writer.writeByte(3);
    writer.write(obj.completed);
    writer.writeByte(4);
    writer.write(obj.levels);
  }
}

// Level Adapter
class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 2;

  @override
  Level read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return Level(
        id: fields[0] as int,
        name: fields[1] as String,
        difficulty: fields[7] as int, // Ensure the field is cast to int
        challengeType:
            fields[8]
                as String, // Replace with the correct field index for 'challengeType'
      )
      ..stars = fields[2] as int
      ..completed = fields[3] as bool
      ..unlocked = fields[4] as bool
      ..highScore = fields[5] as int
      ..bestTime = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.stars);
    writer.writeByte(3);
    writer.write(obj.completed);
    writer.writeByte(4);
    writer.write(obj.unlocked);
    writer.writeByte(5);
    writer.write(obj.highScore);
    writer.writeByte(6);
    writer.write(obj.bestTime);
  }
}

// Achievement Adapter
class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 3;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < numOfFields; i++) {
      final fieldNumber = reader.readByte();
      fields[fieldNumber] = reader.read();
    }

    return Achievement(
      id: fields[0],
      title: fields[1] as String,
      description: fields[2] as String,
      iconId: fields[5] as String,
      dateUnlocked: fields[4] as DateTime,
      rewardCoins: fields[6] as int,
    )..dateUnlocked = fields[3] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.dateUnlocked);
    writer.writeByte(4);
    writer.write(obj.iconId);
    writer.writeByte(5);
    writer.write(obj.rewardCoins);
  }
}
