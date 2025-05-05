import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

class DragDropNumbersChallenge extends StatefulWidget {
  final int level;
  final Function(int score, int stars) onComplete;

  const DragDropNumbersChallenge({
    super.key,
    required this.level,
    required this.onComplete,
    required String operation,
    required int difficulty,
    required int worldId,
  });

  @override
  State<DragDropNumbersChallenge> createState() =>
      _DragDropNumbersChallengeState();
}

class _DragDropNumbersChallengeState extends State<DragDropNumbersChallenge>
    with TickerProviderStateMixin {
  // Controladores
  late AudioPlayer _audioPlayer;
  late AnimationController _timerController;

  // Estado do jogo
  int _score = 0;
  int _timeRemaining = 60; // segundos
  bool _isGameActive = true;
  int _currentProblemIndex = 0;
  int _totalCorrect = 0;

  // Para feedback
  String _feedbackMessage = '';
  bool _showFeedback = false;
  bool _isCorrect = false;

  // Itens do desafio
  List<DraggableItem> _draggableItems = [];
  List<TargetSlot> _targetSlots = [];

  // Lista de problemas para este nível
  late List<Problem> _problems;

  @override
  void initState() {
    super.initState();

    // Inicializa o player de áudio
    _audioPlayer = AudioPlayer();

    // Inicializa o controlador de tempo
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeRemaining),
    );

    _timerController.addListener(() {
      final timeLeft =
          _timeRemaining - (_timerController.value * _timeRemaining).floor();
      if (timeLeft != _timeRemaining) {
        setState(() {
          _timeRemaining = timeLeft;
        });

        if (_timeRemaining <= 0 && _isGameActive) {
          _endGame();
        }
      }
    });

    // Gera os problemas para este nível
    _generateProblems();

    // Configura o primeiro problema
    _setupProblem();

    // Inicia o timer
    _timerController.forward();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _generateProblems() {
    // Lógica baseada no nível para gerar problemas
    final Random random = Random();
    _problems = [];

    // Número de problemas aumenta com o nível
    final problemCount = 5 + widget.level;

    // Dificulta o jogo conforme o nível
    final int maxNumber =
        widget.level <= 1 ? 10 : (widget.level <= 3 ? 20 : 50);

    for (int i = 0; i < problemCount; i++) {
      if (widget.level <= 2) {
        // Níveis 1-2: Ordenação de números
        final List<int> sequence = [];
        final start = random.nextInt(maxNumber - 5);
        for (int j = 0; j < 5; j++) {
          sequence.add(start + j);
        }

        // Embaralha para criar o desafio
        final shuffled = [...sequence]..shuffle();

        _problems.add(
          Problem(
            type: ProblemType.sequence,
            instruction: 'Arraste os números na ordem crescente',
            draggableItems: shuffled.map((n) => n.toString()).toList(),
            targetValues: sequence.map((n) => n.toString()).toList(),
          ),
        );
      } else {
        // Níveis 3+: Completar operações simples
        final int num1 = random.nextInt(maxNumber ~/ 2) + 1;
        final int num2 = random.nextInt(maxNumber ~/ 2) + 1;
        final int result = num1 + num2;

        // Decide qual número esconder (50% de chance para cada)
        final hideFirst = random.nextBool();

        final List<String> targetValues =
            hideFirst
                ? ['?', '+', num2.toString(), '=', result.toString()]
                : [num1.toString(), '+', '?', '=', result.toString()];

        final List<String> draggableItems = [
          ...List.generate(3, (_) => random.nextInt(maxNumber).toString()),
          hideFirst ? num1.toString() : num2.toString(),
        ]..shuffle();

        _problems.add(
          Problem(
            type: ProblemType.operation,
            instruction: 'Complete a operação arrastando o número correto',
            draggableItems: draggableItems,
            targetValues: targetValues,
          ),
        );
      }
    }
  }

  void _setupProblem() {
    if (_currentProblemIndex >= _problems.length) {
      _endGame();
      return;
    }

    final problem = _problems[_currentProblemIndex];

    // Reset do estado
    setState(() {
      _draggableItems = [];
      _targetSlots = [];
      _showFeedback = false;

      // Prepara os itens arrastáveis
      for (int i = 0; i < problem.draggableItems.length; i++) {
        _draggableItems.add(
          DraggableItem(
            id: i,
            value: problem.draggableItems[i],
            isPlaced: false,
          ),
        );
      }

      // Prepara os slots de destino
      for (int i = 0; i < problem.targetValues.length; i++) {
        final isTargetSlot = problem.targetValues[i] == '?';
        _targetSlots.add(
          TargetSlot(
            id: i,
            correctValue: isTargetSlot ? '' : problem.targetValues[i],
            isTargetSlot: isTargetSlot,
            currentItem: null,
          ),
        );
      }
    });
  }

  void _checkAnswer() {
    bool allCorrect = true;

    // Verifica se todos os slots de destino têm o valor correto
    for (final slot in _targetSlots) {
      if (slot.isTargetSlot) {
        final item = slot.currentItem;
        if (item == null) {
          allCorrect = false;
          break;
        }

        // Para problemas de sequência
        if (_problems[_currentProblemIndex].type == ProblemType.sequence) {
          final expectedIndex = _targetSlots.indexOf(slot);
          final expectedValue =
              _problems[_currentProblemIndex].targetValues[expectedIndex];

          if (item.value != expectedValue) {
            allCorrect = false;
            break;
          }
        }
        // Para problemas de operação
        else if (_problems[_currentProblemIndex].type ==
            ProblemType.operation) {
          final operation = _problems[_currentProblemIndex].targetValues;
          final slotIndex = _targetSlots.indexOf(slot);

          if (slotIndex == 0 || slotIndex == 2) {
            // primeiro ou segundo número
            int num1 = 0;
            int num2 = 0;
            int result = 0;

            try {
              // Extrai números da operação
              if (slotIndex == 0) {
                // primeiro número é o slot
                num1 = int.parse(item.value);
                num2 = int.parse(
                  operation[2] == '?'
                      ? (_targetSlots[2].currentItem?.value ?? '0')
                      : operation[2],
                );
              } else {
                // segundo número é o slot
                num1 = int.parse(
                  operation[0] == '?'
                      ? (_targetSlots[0].currentItem?.value ?? '0')
                      : operation[0],
                );
                num2 = int.parse(item.value);
              }

              result = int.parse(operation[4]);

              if (num1 + num2 != result) {
                allCorrect = false;
                break;
              }
            } catch (e) {
              allCorrect = false;
              break;
            }
          }
        }
      }
    }

    setState(() {
      _isCorrect = allCorrect;
      _showFeedback = true;
      _feedbackMessage = allCorrect ? 'Correto!' : 'Tente novamente!';
    });

    // Reproduz som de feedback
    _playFeedbackSound(allCorrect);

    // Se correto, avança para o próximo problema
    if (allCorrect) {
      _totalCorrect++;

      // Adiciona pontos baseado no tempo restante
      final timeBonus = (_timeRemaining / 5).ceil();
      _score += 100 + timeBonus;

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _currentProblemIndex++;
            _showFeedback = false;
          });
          _setupProblem();
        }
      });
    }
  }

  Future<void> _playFeedbackSound(bool correct) async {
    try {
      if (correct) {
        // Implemente o som de acerto
        // await _audioPlayer.setAsset('assets/sounds/correct.mp3');
      } else {
        // Implemente o som de erro
        // await _audioPlayer.setAsset('assets/sounds/wrong.mp3');
      }
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Erro ao reproduzir som: $e');
    }
  }

  void _endGame() {
    if (!_isGameActive) return;

    setState(() {
      _isGameActive = false;
      _timerController.stop();
    });

    // Calcula estrelas baseado no desempenho
    final percentCorrect =
        _problems.isEmpty ? 0 : _totalCorrect / _problems.length;
    final timeBonus = _timeRemaining > 0;

    int stars = 0;
    if (percentCorrect >= 0.8 && timeBonus) {
      stars = 3; // Excelente
    } else if (percentCorrect >= 0.6) {
      stars = 2; // Bom
    } else if (percentCorrect > 0) {
      stars = 1; // Completou
    }

    // Chama o callback com pontuação e estrelas
    widget.onComplete(_score, stars);

    // Mostra diálogo de fim de jogo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showGameCompleteDialog(stars);
      }
    });
  }

  void _showGameCompleteDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(
              stars > 0 ? 'Desafio Completo!' : 'Tente Novamente!',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pontuação: $_score',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                            Icons.star,
                            color:
                                index < stars
                                    ? Colors.amber
                                    : Colors.grey.shade300,
                            size: 40,
                          )
                          .animate(delay: Duration(milliseconds: 300 * index))
                          .scale(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Acertos: $_totalCorrect de ${_problems.length}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Volta para o mapa
                },
                child: const Text('Voltar ao Mapa'),
              ),
              ElevatedButton(
                onPressed:
                    stars < 3
                        ? () {
                          Navigator.of(context).pop();

                          // Reinicia o jogo
                          setState(() {
                            _score = 0;
                            _timeRemaining = 60;
                            _isGameActive = true;
                            _currentProblemIndex = 0;
                            _totalCorrect = 0;
                            _showFeedback = false;
                          });

                          _generateProblems();
                          _setupProblem();
                          _timerController.reset();
                          _timerController.forward();
                        }
                        : null,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final problem =
        _currentProblemIndex < _problems.length
            ? _problems[_currentProblemIndex]
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra superior com pontuação e tempo
              _buildTopBar(),
              const SizedBox(height: 24),

              // Instruções
              if (problem != null)
                Text(
                  problem.instruction,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),

              // Área do problema
              Expanded(child: _buildProblemArea()),

              // Itens para arrastar
              Container(
                height: 120,
                margin: const EdgeInsets.only(top: 24),
                child: _buildDraggableItems(),
              ),

              // Botão de verificar
              _buildCheckButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Botão voltar
        InkWell(
          onTap: () {
            // Confirma saída
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Sair do Desafio?'),
                    content: const Text('Seu progresso será perdido.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 16),

        // Pontuação
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
                const Icon(Icons.stars, color: Color(0xFFFFD747)),
                const SizedBox(width: 8),
                Text(
                  'Pontos: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Tempo restante
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
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
              const Icon(Icons.timer, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 8),
              Text(
                '$_timeRemaining s',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProblemArea() {
    if (_showFeedback) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCorrect ? Icons.check_circle : Icons.cancel,
              color:
                  _isCorrect
                      ? const Color(0xFF42E682)
                      : const Color(0xFFFF6B6B),
              size: 80,
            ).animate().scale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 16),
            Text(
              _feedbackMessage,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    _isCorrect
                        ? const Color(0xFF42E682)
                        : const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      );
    }

    final problem =
        _currentProblemIndex < _problems.length
            ? _problems[_currentProblemIndex]
            : null;

    if (problem == null) return const SizedBox();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _targetSlots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildTargetSlot(slot),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTargetSlot(TargetSlot slot) {
    // Se já tem um item, mostra o item
    if (slot.currentItem != null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF4C6FFF).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4C6FFF), width: 2),
        ),
        child: Center(
          child: Text(
            slot.currentItem!.value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Se é um slot de destino, mostra um espaço para arrastar
    if (slot.isTargetSlot) {
      return DragTarget<DraggableItem>(
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? const Color(0xFF4C6FFF).withValues(alpha: 0.3)
                      : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    candidateData.isNotEmpty
                        ? const Color(0xFF4C6FFF)
                        : Colors.grey,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
        onAcceptWithDetails: (item) {
          setState(() {
            // Marca o item como colocado
            final index = _draggableItems.indexWhere(
              (i) => i.id == item.data.id,
            );
            if (index != -1) {
              _draggableItems[index] = _draggableItems[index].copyWith(
                isPlaced: true,
              );
            }

            // Atribui o item ao slot
            final slotIndex = _targetSlots.indexOf(slot);
            _targetSlots[slotIndex] = _targetSlots[slotIndex].copyWith(
              currentItem: item.data,
            );
          });
        },
      );
    }

    // Caso contrário, mostra apenas o valor
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          slot.correctValue,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDraggableItems() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children:
          _draggableItems.map((item) {
            if (item.isPlaced) {
              // Se o item já foi colocado, mostra um espaço vazio
              return const SizedBox(width: 70);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Draggable<DraggableItem>(
                data: item,
                feedback: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6FFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42E682),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF42E682).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCheckButton() {
    // Verifica se todos os slots de destino têm itens
    final allSlotsFilled = _targetSlots
        .where((slot) => slot.isTargetSlot)
        .every((slot) => slot.currentItem != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed:
            allSlotsFilled && _isGameActive && !_showFeedback
                ? _checkAnswer
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Text(
          'VERIFICAR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Modelos de dados

enum ProblemType { sequence, operation }

class Problem {
  final ProblemType type;
  final String instruction;
  final List<String> draggableItems;
  final List<String> targetValues;

  Problem({
    required this.type,
    required this.instruction,
    required this.draggableItems,
    required this.targetValues,
  });
}

class DraggableItem {
  final int id;
  final String value;
  final bool isPlaced;

  DraggableItem({
    required this.id,
    required this.value,
    required this.isPlaced,
  });

  DraggableItem copyWith({int? id, String? value, bool? isPlaced}) {
    return DraggableItem(
      id: id ?? this.id,
      value: value ?? this.value,
      isPlaced: isPlaced ?? this.isPlaced,
    );
  }
}

class TargetSlot {
  final int id;
  final String correctValue;
  final bool isTargetSlot;
  final DraggableItem? currentItem;

  TargetSlot({
    required this.id,
    required this.correctValue,
    required this.isTargetSlot,
    this.currentItem,
  });

  TargetSlot copyWith({
    int? id,
    String? correctValue,
    bool? isTargetSlot,
    DraggableItem? currentItem,
  }) {
    return TargetSlot(
      id: id ?? this.id,
      correctValue: correctValue ?? this.correctValue,
      isTargetSlot: isTargetSlot ?? this.isTargetSlot,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}
