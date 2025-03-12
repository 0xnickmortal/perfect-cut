import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_state.dart';
import '../widgets/level_button.dart';
import '../utils/translations.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  // 播放UI交互声音
  void _playUISound() async {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('audio/ui.mp3'), volume: 0.3);
      } catch (e) {
        // 音频播放失败时的静默处理
        debugPrint('无法播放UI声音: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isEnglish = gameState.isEnglish;
    
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(tr('select_level', isEnglish), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 星星和完美次数统计
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 星星统计
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${gameState.stars}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 完美切割次数
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${gameState.perfectCuts}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 500),
              ),
              
              const SizedBox(height: 30),
              
              // 关卡列表
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: gameState.levels.length,
                  itemBuilder: (context, index) {
                    final isUnlocked = gameState.unlockedLevels[index];
                    
                    return LevelButton(
                      level: index + 1,
                      isUnlocked: isUnlocked,
                      isEnglish: isEnglish,
                      onTap: isUnlocked ? () {
                        _playUISound();
                        gameState.setCurrentLevel(index);
                        Navigator.of(context).pushNamed('/game');
                      } : null,
                      animationDelay: 100 * index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 