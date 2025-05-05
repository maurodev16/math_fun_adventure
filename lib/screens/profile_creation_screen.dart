import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../widgets/avatar_selector.dart';
import 'game_map_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAvatarId = 'avatar_default';
  bool _isLoading = false;

  // Lista de avatares disponíveis inicialmente
  final List<AvatarOption> _initialAvatars = [
    AvatarOption(
      id: 'avatar_default',
      assetPath: 'assets/avatars/default.png',
      name: 'Estudante',
    ),
    AvatarOption(
      id: 'avatar_girl',
      assetPath: 'assets/avatars/girl.png',
      name: 'Estudante',
    ),
    AvatarOption(
      id: 'avatar_boy',
      assetPath: 'assets/avatars/boy.png',
      name: 'Estudante',
    ),
    AvatarOption(
      id: 'avatar_cat',
      assetPath: 'assets/avatars/cat.png',
      name: 'Gatinho',
    ),
    AvatarOption(
      id: 'avatar_dog',
      assetPath: 'assets/avatars/dog.png',
      name: 'Cachorrinho',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Cria o perfil do jogador e navega para a tela principal
  Future<void> _createProfile() async {
    // Valida o nome
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, digite seu nome!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Cria o perfil usando o provider
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final success = await playerProvider.createNewPlayer(
      name,
      _selectedAvatarId,
    );

    setState(() {
      _isLoading = false;
    });

    // Se sucesso, navega para a tela do mapa
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GameMapScreen()),
      );
    } else {
      // Mostra erro, se houver
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            playerProvider.errorMessage ??
                'Erro ao criar perfil. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),

                      // Logo e título
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // Formulário de criação de perfil
                      _buildProfileForm(),
                      const SizedBox(height: 32),

                      // Botão de criação
                      _buildCreateButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo do jogo
        Image.asset(
          'assets/images/logo.png',
          height: 120,
          fit: BoxFit.contain,
        ).animate().scale(
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 24),

        // Título e subtítulo
        const Text(
          'Math Fun Adventure',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C6FFF),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Crie seu perfil para começar a aventura!',
          style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de nome
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Como devemos chamar você?',
                hintText: 'Digite seu nome ou apelido',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 15,
            ),
            const SizedBox(height: 24),

            // Título para seleção de avatar
            const Text(
              'Escolha seu avatar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Seletor de avatar
            AvatarSelector(
              avatarOptions: _initialAvatars,
              selectedAvatarId: _selectedAvatarId,
              onAvatarSelected: (avatarId) {
                setState(() {
                  _selectedAvatarId = avatarId;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _createProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42E682),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      child: const Text(
        'COMEÇAR AVENTURA',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 300),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
