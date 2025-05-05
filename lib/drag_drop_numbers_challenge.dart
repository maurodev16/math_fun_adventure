import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'dart:async';

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
  // Audio Controllers
  late AudioPlayer _musicPlayer;
  late AudioPlayer _effectsPlayer;
  late AudioPlayer _feedbackPlayer;

  // Animation Controllers
  late AnimationController _timerController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;

  // Game State
  int _score = 0;
  int _timeRemaining = 60; // seconds
  bool _isGameActive = true;
  int _currentProblemIndex = 0;
  int _totalCorrect = 0;
  bool _isMusicOn = true;

  // Feedback
  String _feedbackMessage = '';
  bool _showFeedback = false;
  bool _isCorrect = false;

  // Particle effects
  List<ParticleEffect> _particles = [];
  Timer? _particleTimer;

  // Challenge items
  List<DraggableItem> _draggableItems = [];
  List<TargetSlot> _targetSlots = [];

  // Problem list for this level
  late List<Problem> _problems;

  @override
  void initState() {
    super.initState();

    // Initialize audio players
    _musicPlayer = AudioPlayer();
    _effectsPlayer = AudioPlayer();
    _feedbackPlayer = AudioPlayer();

    // Start background music
    _startBackgroundMusic();

    // Initialize timer controller
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeRemaining),
    );

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Initialize shake animation controller
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _timerController.addListener(() {
      final timeLeft =
          _timeRemaining - (_timerController.value * _timeRemaining).floor();
      if (timeLeft != _timeRemaining) {
        setState(() {
          _timeRemaining = timeLeft;
        });

        // Play ticking sound when time is low
        if (_timeRemaining <= 10 && _timeRemaining > 0) {
          _playTimerTickSound();
        }

        if (_timeRemaining <= 0 && _isGameActive) {
          _endGame();
        }
      }
    });

    // Generate problems for this level
    _generateProblems();

    // Setup first problem
    _setupProblem();

    // Start timer
    _timerController.forward();

    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    _effectsPlayer.dispose();
    _feedbackPlayer.dispose();
    _timerController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  Future<void> _startBackgroundMusic() async {
    try {
      await _musicPlayer.setAsset('assets/sounds/game-background.mp3');
      await _musicPlayer.setLoopMode(LoopMode.all);
      await _musicPlayer.setVolume(0.3);

      if (_isMusicOn) {
        await _musicPlayer.play();
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> _playTimerTickSound() async {
    try {
      await _effectsPlayer.setAsset('assets/sounds/timer-tick.mp3');
      await _effectsPlayer.setVolume(0.2);
      await _effectsPlayer.play();
    } catch (e) {
      debugPrint('Error playing timer sound: $e');
    }
  }

  Future<void> _playDragSound() async {
    try {
      await _effectsPlayer.setAsset('assets/sounds/drag.mp3');
      await _effectsPlayer.setVolume(0.5);
      await _effectsPlayer.play();
    } catch (e) {
      debugPrint('Error playing drag sound: $e');
    }
  }

  Future<void> _playDropSound() async {
    try {
      await _effectsPlayer.setAsset('assets/sounds/drop.mp3');
      await _effectsPlayer.setVolume(0.5);
      await _effectsPlayer.play();
    } catch (e) {
      debugPrint('Error playing drop sound: $e');
    }
  }

  void _generateProblems() {
    final Random random = Random();
    _problems = [];

    // Number of problems increases with level
    final problemCount = 5 + widget.level;

    // Game difficulty increases with level
    final int maxNumber =
        widget.level <= 1 ? 10 : (widget.level <= 3 ? 20 : 50);

    for (int i = 0; i < problemCount; i++) {
      if (widget.level <= 2) {
        // Levels 1-2: Sequence ordering
        final List<int> sequence = [];
        final start = random.nextInt(maxNumber - 5);
        for (int j = 0; j < 5; j++) {
          sequence.add(start + j);
        }

        // Shuffle for challenge
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
        // Levels 3+: Complete simple operations
        final int num1 = random.nextInt(maxNumber ~/ 2) + 1;
        final int num2 = random.nextInt(maxNumber ~/ 2) + 1;
        final int result = num1 + num2;

        // Decide which number to hide (50% chance for each)
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

    // Reset state
    setState(() {
      _draggableItems = [];
      _targetSlots = [];
      _showFeedback = false;
      _particles = [];

      // Prepare draggable items
      for (int i = 0; i < problem.draggableItems.length; i++) {
        _draggableItems.add(
          DraggableItem(
            id: i,
            value: problem.draggableItems[i],
            isPlaced: false,
          ),
        );
      }

      // Prepare target slots
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

    // Check if all target slots have the correct value
    for (final slot in _targetSlots) {
      if (slot.isTargetSlot) {
        final item = slot.currentItem;
        if (item == null) {
          allCorrect = false;
          break;
        }

        // For sequence problems
        if (_problems[_currentProblemIndex].type == ProblemType.sequence) {
          final expectedIndex = _targetSlots.indexOf(slot);
          final expectedValue =
              _problems[_currentProblemIndex].targetValues[expectedIndex];

          if (item.value != expectedValue) {
            allCorrect = false;
            break;
          }
        }
        // For operation problems
        else if (_problems[_currentProblemIndex].type ==
            ProblemType.operation) {
          final operation = _problems[_currentProblemIndex].targetValues;
          final slotIndex = _targetSlots.indexOf(slot);

          if (slotIndex == 0 || slotIndex == 2) {
            // first or second number
            int num1 = 0;
            int num2 = 0;
            int result = 0;

            try {
              // Extract numbers from operation
              if (slotIndex == 0) {
                // first number is the slot
                num1 = int.parse(item.value);
                num2 = int.parse(
                  operation[2] == '?'
                      ? (_targetSlots[2].currentItem?.value ?? '0')
                      : operation[2],
                );
              } else {
                // second number is the slot
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

      if (allCorrect) {
        _generateParticles();
      } else {
        // Shake animation for incorrect answers
        _shakeController.reset();
        _shakeController.forward();
      }
    });

    // Play feedback sound
    _playFeedbackSound(allCorrect);

    // Haptic feedback
    if (allCorrect) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }

    // If correct, advance to next problem
    if (allCorrect) {
      _totalCorrect++;

      // Add points based on remaining time
      final timeBonus = (_timeRemaining / 5).ceil();
      _score += 100 + timeBonus;

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _currentProblemIndex++;
            _showFeedback = false;
            _particles = [];
          });
          _setupProblem();
        }
      });
    }
  }

  void _generateParticles() {
    // Generate celebration particles
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * screenSize.width;
      final y = screenSize.height / 2;

      _particles.add(
        ParticleEffect(
          x: x,
          y: y,
          color: Color.fromARGB(
            255,
            random.nextInt(255),
            random.nextInt(255),
            random.nextInt(255),
          ),
          size: random.nextDouble() * 10 + 5,
          speedX: (random.nextDouble() - 0.5) * 10,
          speedY: -random.nextDouble() * 15 - 5,
        ),
      );
    }

    // Animate particles
    _particleTimer?.cancel();
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || !_showFeedback || !_isCorrect) {
        timer.cancel();
        return;
      }

      setState(() {
        for (int i = 0; i < _particles.length; i++) {
          final particle = _particles[i];
          particle.y += particle.speedY;
          particle.x += particle.speedX;
          particle.speedY += 0.3; // Gravity
          particle.size -= 0.1;

          if (particle.size <= 0) {
            _particles[i] = ParticleEffect(
              x: random.nextDouble() * screenSize.width,
              y: screenSize.height / 2,
              color: Color.fromARGB(
                255,
                random.nextInt(255),
                random.nextInt(255),
                random.nextInt(255),
              ),
              size: random.nextDouble() * 10 + 5,
              speedX: (random.nextDouble() - 0.5) * 10,
              speedY: -random.nextDouble() * 15 - 5,
            );
          }
        }
      });
    });
  }

  Future<void> _playFeedbackSound(bool correct) async {
    try {
      if (correct) {
        await _feedbackPlayer.setAsset('assets/sounds/correct.mp3');
      } else {
        await _feedbackPlayer.setAsset('assets/sounds/game-fail.mp3');
      }
      await _feedbackPlayer.play();
    } catch (e) {
      debugPrint('Error playing feedback sound: $e');
    }
  }

  void _endGame() {
    if (!_isGameActive) return;

    setState(() {
      _isGameActive = false;
      _timerController.stop();
    });

    // Calculate stars based on performance
    final percentCorrect =
        _problems.isEmpty ? 0 : _totalCorrect / _problems.length;
    final timeBonus = _timeRemaining > 0;

    int stars = 0;
    if (percentCorrect >= 0.8 && timeBonus) {
      stars = 3; // Excellent
    } else if (percentCorrect >= 0.6) {
      stars = 2; // Good
    } else if (percentCorrect > 0) {
      stars = 1; // Completed
    }

    // Call callback with score and stars
    widget.onComplete(_score, stars);

    // Show game complete dialog
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
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              stars > 0 ? 'Desafio Completo!' : 'Tente Novamente!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4C6FFF),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE9F0FF), Color(0xFFD4E2FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Pontuação: $_score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Icon(
                                  Icons.star,
                                  color:
                                      index < stars
                                          ? const Color(0xFFFFD747)
                                          : Colors.grey.shade300,
                                  size: 50,
                                )
                                .animate(
                                  delay: Duration(milliseconds: 300 * index),
                                )
                                .scale(
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.elasticOut,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Acertos: $_totalCorrect de ${_problems.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Back to map
                    },
                    icon: const Icon(Icons.map, color: Color(0xFF4C6FFF)),
                    label: const Text(
                      'Voltar ao Mapa',
                      style: TextStyle(
                        color: Color(0xFF4C6FFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed:
                        stars < 3
                            ? () {
                              Navigator.of(context).pop();

                              // Restart game
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
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Tentar Novamente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42E682),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9F0FF), Color(0xFFD4E2FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top bar with score and time
                    _buildTopBar(),
                    const SizedBox(height: 24),

                    // Instructions
                    if (problem != null)
                      Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
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
                            child: Text(
                              problem.instruction,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          .animate()
                          .fade(duration: const Duration(milliseconds: 500))
                          .slideY(
                            begin: -0.2,
                            duration: const Duration(milliseconds: 500),
                          ),
                    const SizedBox(height: 40),

                    // Problem area
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final offset =
                              _isCorrect
                                  ? 0.0
                                  : sin(_shakeController.value * 10 * pi) *
                                      10.0;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: _buildProblemArea(),
                      ),
                    ),

                    // Draggable items
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 120,
                      margin: const EdgeInsets.only(top: 24),
                      child: _buildDraggableItems(),
                    ),

                    // Check button
                    _buildCheckButton(),
                  ],
                ),

                // Particles
                if (_particles.isNotEmpty && _showFeedback && _isCorrect)
                  CustomPaint(
                    size: Size.infinite,
                    painter: ParticlePainter(particles: _particles),
                  ),

                // Sound toggle button
                Positioned(
                  top: 16,
                  right: 16,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isMusicOn = !_isMusicOn;
                      });

                      if (_isMusicOn) {
                        _musicPlayer.play();
                      } else {
                        _musicPlayer.pause();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isMusicOn ? Icons.volume_up : Icons.volume_off,
                        color: const Color(0xFF4C6FFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button
        InkWell(
          onTap: () {
            // Confirm exit
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Sair do Desafio?',
                      style: TextStyle(
                        color: Color(0xFF4C6FFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'Seu progresso será perdido.',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6FFF), Color(0xFF6A8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4C6FFF).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),

        // Score
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD747), Color(0xFFFFE47A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD747).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Pontos: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Remaining time
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                _timeRemaining <= 10 ? 1.0 + _pulseController.value * 0.2 : 1.0;
            final color =
                _timeRemaining <= 10
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF42E682);

            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_timeRemaining s',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
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
              size: 100,
            ).animate().scale(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            Text(
              _feedbackMessage,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color:
                    _isCorrect
                        ? const Color(0xFF42E682)
                        : const Color(0xFFFF6B6B),
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color:
                        _isCorrect
                            ? const Color(0xFF42E682).withValues(alpha: 0.5)
                            : const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: 0.5, end: 0),
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
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF5F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
          )
          .animate()
          .fade(duration: const Duration(milliseconds: 500))
          .slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutQuad,
          ),
    );
  }

  Widget _buildTargetSlot(TargetSlot slot) {
    // If already has an item, show the item
    if (slot.currentItem != null) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C6FFF), Color(0xFF6A8CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C6FFF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            slot.currentItem!.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
      );
    }

    // If it's a target slot, show a space to drag
    if (slot.isTargetSlot) {
      return DragTarget<DraggableItem>(
        builder: (context, candidateData, rejectedData) {
          return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        candidateData.isNotEmpty
                            ? [
                              const Color(0xFF4C6FFF).withValues(alpha: 0.7),
                              const Color(0xFF6A8CFF).withValues(alpha: 0.7),
                            ]
                            : [Colors.grey.shade200, Colors.grey.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        candidateData.isNotEmpty
                            ? const Color(0xFF4C6FFF)
                            : Colors.grey.shade400,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                  boxShadow:
                      candidateData.isNotEmpty
                          ? [
                            BoxShadow(
                              color: const Color(
                                0xFF4C6FFF,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : [],
                ),
                child: Center(
                  child: Icon(
                    Icons.touch_app,
                    color:
                        candidateData.isNotEmpty
                            ? Colors.white
                            : Colors.grey.shade500,
                    size: 32,
                  ),
                ),
              )
              .animate(target: candidateData.isNotEmpty ? 1 : 0)
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: const Duration(milliseconds: 200),
              );
        },
        onWillAcceptWithDetails: (item) {
          // Play hover sound effect
          _playDropSound();
          return true;
        },
        onAcceptWithDetails: (item) {
          setState(() {
            // Mark the item as placed
            final index = _draggableItems.indexWhere(
              (i) => i.id == item.data.id,
            );
            if (index != -1) {
              _draggableItems[index] = _draggableItems[index].copyWith(
                isPlaced: true,
              );
            }

            // Assign the item to the slot
            final slotIndex = _targetSlots.indexOf(slot);
            _targetSlots[slotIndex] = _targetSlots[slotIndex].copyWith(
              currentItem: item.data,
            );
          });

          // Add haptic feedback
          HapticFeedback.selectionClick();
        },
      );
    }

    // Otherwise, just show the value
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          slot.correctValue,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
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
              // If the item is already placed, show an empty space
              return const SizedBox(width: 80);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Draggable<DraggableItem>(
                    data: item,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF42E682), Color(0xFF3BD67A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF42E682,
                              ).withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            item.value,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onDragStarted: () {
                      _playDragSound();
                      HapticFeedback.lightImpact();
                    },
                    childWhenDragging: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5),
                          width: 3,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF42E682), Color(0xFF3BD67A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF42E682,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          item.value,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fade(duration: const Duration(milliseconds: 500))
                  .scale(
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: item.id * 100),
                    curve: Curves.elasticOut,
                  ),
            );
          }).toList(),
    );
  }

  Widget _buildCheckButton() {
    // Check if all target slots have items
    final allSlotsFilled = _targetSlots
        .where((slot) => slot.isTargetSlot)
        .every((slot) => slot.currentItem != null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
            onPressed:
                allSlotsFilled && _isGameActive && !_showFeedback
                    ? _checkAnswer
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              minimumSize: const Size(220, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'VERIFICAR',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          ),
    );
  }
}

// Particle effect for celebrations
class ParticleEffect {
  double x;
  double y;
  Color color;
  double size;
  double speedX;
  double speedY;

  ParticleEffect({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedX,
    required this.speedY,
  });
}

class ParticlePainter extends CustomPainter {
  final List<ParticleEffect> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models

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
