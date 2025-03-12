import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/level_select_screen.dart';
import 'models/game_state.dart';
import 'utils/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置屏幕方向为纵向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: Consumer<GameState>(
        builder: (context, gameState, child) {
          final bool isEnglish = gameState.isEnglish;
          return MaterialApp(
            title: tr('app_title', isEnglish),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              '/levels': (context) => const LevelSelectScreen(),
              '/game': (context) => const GameScreen(),
            },
          );
        }
      ),
    );
  }
}
