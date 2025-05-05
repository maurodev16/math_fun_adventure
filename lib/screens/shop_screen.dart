import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/player_data_service.dart';
import '../providers/player_provider.dart';
import '../widgets/coin_display.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Categorias de itens da loja
  final List<String> _categories = [
    'Avatares',
    'Temas',
    'Power-ups',
    'Molduras',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Lista de itens da loja por categoria
  List<ShopItem> _getItemsByCategory(String category) {
    switch (category) {
      case 'Avatares':
        return [
          ShopItem(
            id: 'avatar_wizard',
            name: 'Mago da Matemática',
            description: 'Um sábio mago especialista em números',
            cost: 150,
            imageAsset: 'assets/shop/avatar_wizard.png',
            category: 'Avatares',
          ),
          ShopItem(
            id: 'avatar_astronaut',
            name: 'Astronauta Numérico',
            description: 'Explorando o universo da matemática',
            cost: 200,
            imageAsset: 'assets/shop/avatar_astronaut.png',
            category: 'Avatares',
          ),
          ShopItem(
            id: 'avatar_robot',
            name: 'Robô Calculador',
            description: 'Um robô que adora resolver problemas',
            cost: 250,
            imageAsset: 'assets/shop/avatar_robot.png',
            category: 'Avatares',
          ),
          ShopItem(
            id: 'avatar_scientist',
            name: 'Cientista Matemático',
            description: 'Sempre fazendo experimentos com números',
            cost: 300,
            imageAsset: 'assets/shop/avatar_scientist.png',
            category: 'Avatares',
          ),
        ];
      case 'Temas':
        return [
          ShopItem(
            id: 'theme_space',
            name: 'Tema Espacial',
            description: 'Um tema com planetas e estrelas',
            cost: 100,
            imageAsset: 'assets/shop/theme_space.png',
            category: 'Temas',
          ),
          ShopItem(
            id: 'theme_underwater',
            name: 'Tema Submarino',
            description: 'Explore o fundo do mar enquanto aprende',
            cost: 120,
            imageAsset: 'assets/shop/theme_underwater.png',
            category: 'Temas',
          ),
          ShopItem(
            id: 'theme_jungle',
            name: 'Tema Selva',
            description: 'Uma aventura matemática pela selva',
            cost: 120,
            imageAsset: 'assets/shop/theme_jungle.png',
            category: 'Temas',
          ),
        ];
      case 'Power-ups':
        return [
          ShopItem(
            id: 'powerup_hint',
            name: 'Dica Extra',
            description: 'Receba uma dica durante o desafio',
            cost: 50,
            imageAsset: 'assets/shop/powerup_hint.png',
            category: 'Power-ups',
            consumable: true,
          ),
          ShopItem(
            id: 'powerup_time',
            name: 'Tempo Extra',
            description: '+30 segundos em desafios com tempo',
            cost: 75,
            imageAsset: 'assets/shop/powerup_time.png',
            category: 'Power-ups',
            consumable: true,
          ),
          ShopItem(
            id: 'powerup_skip',
            name: 'Pular Pergunta',
            description: 'Pule uma pergunta difícil (uma vez por nível)',
            cost: 100,
            imageAsset: 'assets/shop/powerup_skip.png',
            category: 'Power-ups',
            consumable: true,
          ),
        ];
      case 'Molduras':
        return [
          ShopItem(
            id: 'frame_gold',
            name: 'Moldura Dourada',
            description: 'Uma moldura dourada para seu avatar',
            cost: 300,
            imageAsset: 'assets/shop/frame_gold.png',
            category: 'Molduras',
          ),
          ShopItem(
            id: 'frame_silver',
            name: 'Moldura Prateada',
            description: 'Uma moldura prateada para seu avatar',
            cost: 200,
            imageAsset: 'assets/shop/frame_silver.png',
            category: 'Molduras',
          ),
          ShopItem(
            id: 'frame_bronze',
            name: 'Moldura Bronze',
            description: 'Uma moldura de bronze para seu avatar',
            cost: 150,
            imageAsset: 'assets/shop/frame_bronze.png',
            category: 'Molduras',
          ),
        ];
      default:
        return [];
    }
  }

  // Compra um item da loja
  Future<void> _purchaseItem(ShopItem item) async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    // Tenta comprar o item
    final success = await PlayerDataService.purchaseItem(item.id, item.cost);

    // Atualiza o provider com os dados atualizados
    if (success) {
      await playerProvider.refreshPlayerData();

      // Mostra mensagem de sucesso
      _showPurchaseResult(
        success: true,
        message: 'Item comprado com sucesso!',
        item: item,
      );
    } else {
      // Mostra mensagem de erro
      _showPurchaseResult(
        success: false,
        message: 'Moedas insuficientes para comprar este item.',
        item: item,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Mostra diálogo com resultado da compra
  void _showPurchaseResult({
    required bool success,
    required String message,
    required ShopItem item,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              success ? 'Compra Realizada!' : 'Não foi possível comprar',
              style: TextStyle(
                color:
                    success
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (success)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.contain,
                    ).animate().scale(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                if (success && item.consumable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Este item estará disponível no seu próximo desafio!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
      appBar: AppBar(
        title: const Text('Loja Matemática'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Exibe as moedas do jogador
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              return CoinDisplay(coins: playerProvider.player?.coins ?? 0);
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories.map((category) => Tab(text: category)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children:
                    _categories.map((category) {
                      final items = _getItemsByCategory(category);
                      return _buildCategoryItems(items);
                    }).toList(),
              ),
    );
  }

  // Constrói a lista de itens de uma categoria
  Widget _buildCategoryItems(List<ShopItem> items) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final player = playerProvider.player;
        final unlockedItems = player?.unlockedItems ?? [];

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isUnlocked = unlockedItems.contains(item.id);

            return _buildShopItemCard(
              context,
              item,
              isUnlocked,
              player?.coins ?? 0,
            );
          },
        );
      },
    );
  }

  // Constrói um card de item da loja
  Widget _buildShopItemCard(
    BuildContext context,
    ShopItem item,
    bool isUnlocked,
    int playerCoins,
  ) {
    final hasEnoughCoins = playerCoins >= item.cost;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isUnlocked
                ? BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: isUnlocked ? null : () => _purchaseItem(item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagem do item
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Imagem com efeito de opacity se estiver bloqueado
                    Opacity(
                      opacity: isUnlocked || hasEnoughCoins ? 1.0 : 0.5,
                      child: Image.asset(item.imageAsset, fit: BoxFit.contain),
                    ),

                    // Badge de desbloqueado
                    if (isUnlocked)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Nome do item
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 4),

              // Descrição do item
              Text(
                item.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 8),

              // Preço ou status
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Desbloqueado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.attach_money,
                      color:
                          hasEnoughCoins
                              ? const Color(0xFFFFD747)
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.cost.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color:
                            hasEnoughCoins
                                ? const Color(0xFF333333)
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelo para itens da loja
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String imageAsset;
  final String category;
  final bool consumable;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.imageAsset,
    required this.category,
    this.consumable = false,
  });
}
