import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'services/player_data_service.dart';
import 'providers/player_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_creation_screen.dart';
import 'screens/game_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura a orientação do app para retrato
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa o Hive para persistência de dados
  await PlayerDataService.initialize();

  // Configura preferências de animação (duração global)
  Animate.defaultDuration = const Duration(milliseconds: 300);

  runApp(const MathFunAdventureApp());
}

class MathFunAdventureApp extends StatelessWidget {
  const MathFunAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Math Fun Adventure',
        theme: ThemeData(
          primaryColor: const Color(0xFF4C6FFF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4C6FFF),
            secondary: const Color(0xFF42E682),
            tertiary: const Color(0xFFFFD747),
          ),
          fontFamily: 'Quicksand',
          useMaterial3: true,
          // Define estilos globais para botões e cards
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
          // Estilo para AppBar
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF4C6FFF),
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const AppStartupController(),
      ),
    );
  }
}

// Controller para decidir qual tela mostrar primeiro
class AppStartupController extends StatefulWidget {
  const AppStartupController({super.key});

  @override
  State<AppStartupController> createState() => _AppStartupControllerState();
}

class _AppStartupControllerState extends State<AppStartupController> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask para agendar a inicialização após a construção do widget
    Future.microtask(_initializeApp);
  }

  // Inicializa os dados do jogador e decide para qual tela navegar
  Future<void> _initializeApp() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    await playerProvider.initialize();

    // Só atualize o estado se o widget ainda estiver montado
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostra SplashScreen enquanto inicializa
    if (!_isInitialized) {
      return const SplashScreen();
    }

    // Depois de inicializado, decide qual tela mostrar baseado no estado do jogador
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (playerProvider.hasPlayer) {
      // Se já existe um jogador, mostra a tela do mapa
      return const GameMapScreen();
    } else {
      // Se não existe jogador, mostra a tela de criação de perfil
      return const ProfileCreationScreen();
    }
  }
}
