import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../drag_drop_numbers_challenge.dart';
import '../providers/player_provider.dart';

class ChallengeScreen extends StatefulWidget {
  final int worldId;
  final int levelId;
  final String operation;
  final int difficulty;
  final String challengeType;

  const ChallengeScreen({
    super.key,
    required this.worldId,
    required this.levelId,
    required this.operation,
    required this.difficulty,
    required this.challengeType,
  });

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _isLoading = true;
  String _challengeTitle = '';
  String _challengeDescription = '';

  @override
  void initState() {
    super.initState();
    _loadChallengeInfo();
  }

  // Carrega informações sobre o desafio
  Future<void> _loadChallengeInfo() async {
    // Simulação de carregamento (poderia buscar de uma API ou banco de dados)
    await Future.delayed(const Duration(milliseconds: 500));

    // Define informações do desafio com base nos parâmetros
    setState(() {
      _challengeTitle = _getChallengeTitle();
      _challengeDescription = _getChallengeDescription();
      _isLoading = false;
    });
  }

  // Obtém o título do desafio
  String _getChallengeTitle() {
    final worldName = _getWorldName();
    return 'Nível ${widget.levelId} - $worldName';
  }

  // Obtém a descrição do desafio
  String _getChallengeDescription() {
    switch (widget.operation) {
      case 'sequence':
        return 'Organize os números na ordem correta para completar o padrão.';
      case 'addition':
        return 'Arraste os números para resolver as somas.';
      case 'subtraction':
        return 'Descubra quanto falta para completar as subtrações.';
      case 'multiplication':
        return 'Multiplique os números para encontrar o resultado correto.';
      case 'division':
        return 'Divida os números para encontrar o resultado correto.';
      case 'fractions':
        return 'Complete as operações com frações.';
      default:
        return 'Resolva o desafio matemático!';
    }
  }

  // Obtém o nome do mundo
  String _getWorldName() {
    switch (widget.worldId) {
      case 1:
        return 'Ilha dos Números';
      case 2:
        return 'Floresta da Adição';
      case 3:
        return 'Caverna da Subtração';
      case 4:
        return 'Castelo da Multiplicação';
      case 5:
        return 'Oceano da Divisão';
      case 6:
        return 'Laboratório das Frações';
      default:
        return 'Mundo Matemático';
    }
  }

  // Obtém o ícone do desafio
  IconData _getChallengeIcon() {
    switch (widget.operation) {
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

  // Obtém a cor do mundo
  Color _getWorldColor() {
    switch (widget.worldId) {
      case 1:
        return const Color(0xFF42E682); // Verde
      case 2:
        return const Color(0xFF4C6FFF); // Azul
      case 3:
        return const Color(0xFF9D71EA); // Roxo
      case 4:
        return const Color(0xFFFFD747); // Amarelo
      case 5:
        return const Color(0xFFFF6B6B); // Vermelho
      case 6:
        return const Color(0xFF00BCD4); // Ciano
      default:
        return Colors.grey;
    }
  }

  // Completa o desafio e atualiza o progresso
  void _completeChallenge(int score, int stars) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    // Tempo estimado (poderia ser medido com precisão)
    const timeInSeconds = 60;

    // Atualiza o progresso do jogador
    playerProvider.completeLevel(
      worldId: widget.worldId,
      levelId: widget.levelId,
      score: score,
      stars: stars,
      timeInSeconds: timeInSeconds,
    );

    // Retorna para a tela anterior
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildChallenge(),
    );
  }

  // Constrói o desafio apropriado
  Widget _buildChallenge() {
    // Tela introdutória do desafio
    return SafeArea(
      child: Column(
        children: [
          // Cabeçalho do desafio
          _buildChallengeHeader(),

          // Corpo do desafio
          Expanded(child: _buildChallengeContent()),
        ],
      ),
    );
  }

  // Constrói o cabeçalho do desafio
  Widget _buildChallengeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getWorldColor(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Botão de voltar e título
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  _challengeTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Espaço para balancear o layout
            ],
          ),

          // Ícone do desafio
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(_getChallengeIcon(), color: _getWorldColor(), size: 36),
          ),

          const SizedBox(height: 12),

          // Descrição do desafio
          Text(
            _challengeDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 12),

          // Nível de dificuldade
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Dificuldade: ',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              ...List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color:
                      index < widget.difficulty
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Constrói o conteúdo do desafio
  Widget _buildChallengeContent() {
    // Baseado no tipo de desafio, carrega o componente adequado
    switch (widget.challengeType) {
      case 'sequence':
      case 'operation':
        // Desafio de arrastar e soltar (para sequências e operações)
        return DragDropNumbersChallenge(
          level: widget.levelId,
          operation: widget.operation,
          difficulty: widget.difficulty,
          worldId: widget.worldId,
          onComplete: _completeChallenge,
        );
      // Outros tipos de desafios podem ser adicionados aqui
      default:
        // Fallback para um desafio genérico
        return DragDropNumbersChallenge(
          level: widget.levelId,
          operation: widget.operation,
          difficulty: widget.difficulty,
          worldId: widget.worldId,
          onComplete: _completeChallenge,
        );
    }
  }
}
