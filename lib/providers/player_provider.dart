import 'package:flutter/foundation.dart';
import '../models/player_model.dart';
import '../services/player_data_service.dart';

class PlayerProvider with ChangeNotifier {
  Player? _player;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Player? get player => _player;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasPlayer => _player != null;

  // Inicializa carregando o jogador
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Verifica se existe um jogador salvo
      if (PlayerDataService.hasExistingPlayer()) {
        _player = PlayerDataService.loadPlayer();

        // Verifica login diário
        final dailyReward = await PlayerDataService.checkDailyLogin();
        if (dailyReward != null) {
          // Atualiza o jogador após receber a recompensa diária
          _player = PlayerDataService.loadPlayer();
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados do jogador: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Cria um novo jogador
  Future<bool> createNewPlayer(String name, String avatarId) async {
    _setLoading(true);

    try {
      _player = await PlayerDataService.createNewPlayer(name, avatarId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao criar novo jogador: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualiza os dados do jogador a partir do armazenamento
  Future<void> refreshPlayerData() async {
    _setLoading(true);

    try {
      _player = PlayerDataService.loadPlayer();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar dados do jogador: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Completa um nível
  Future<void> completeLevel({
    required int worldId,
    required int levelId,
    required int score,
    required int stars,
    required int timeInSeconds,
  }) async {
    _setLoading(true);

    try {
      await PlayerDataService.updateLevelProgress(
        worldId: worldId,
        levelId: levelId,
        score: score,
        stars: stars,
        timeInSeconds: timeInSeconds,
      );

      // Atualiza os dados após a alteração
      await refreshPlayerData();
    } catch (e) {
      _errorMessage = 'Erro ao atualizar progresso do nível: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Compra um item da loja
  Future<bool> purchaseItem(String itemId, int cost) async {
    _setLoading(true);

    try {
      final success = await PlayerDataService.purchaseItem(itemId, cost);

      if (success) {
        // Atualiza os dados após a compra bem-sucedida
        await refreshPlayerData();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Erro ao comprar item: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Registra o tempo de jogo
  Future<void> trackGameSession(int playTimeSecs) async {
    try {
      await PlayerDataService.trackGameSession(playTimeSecs);
      await refreshPlayerData();
    } catch (e) {
      debugPrint('Erro ao registrar sessão de jogo: $e');
    }
  }

  // Altera o estado de carregamento e notifica os ouvintes
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset de todas as informações
  Future<void> resetAllData() async {
    _setLoading(true);

    try {
      await PlayerDataService.resetAllData();
      _player = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao resetar dados: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
}
