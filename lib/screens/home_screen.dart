import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_state.dart';
import '../widgets/menu_button.dart';
import '../utils/translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final screenSize = MediaQuery.of(context).size;
    final isEnglish = gameState.isEnglish;
    
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
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
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // 游戏标题
                  Text(
                    tr('app_title', isEnglish),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.blue.shade200,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: -0.2, 
                    end: 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 完美切割次数统计
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      tr('perfect_cuts', isEnglish, params: {'count': gameState.perfectCuts.toString()}),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 500)),
                  
                  // 游戏Logo
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: screenSize.width * 0.6,
                        height: screenSize.width * 0.6,
                        child: CustomPaint(
                          painter: HomeLogo(isEnglish: isEnglish),
                        ),
                      )
                      .animate()
                      .scale(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                      ),
                    ),
                  ),
                  
                  // 菜单按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // 开始游戏按钮
                        MenuButton(
                          text: tr('start_game', isEnglish),
                          icon: Icons.play_arrow_rounded,
                          onTap: () {
                            _playUISound();
                            Navigator.of(context).pushNamed('/levels');
                          },
                          animationDelay: 400,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 声音开关按钮
                        MenuButton(
                          text: gameState.soundEnabled 
                              ? tr('sound_off', isEnglish)
                              : tr('sound_on', isEnglish),
                          icon: gameState.soundEnabled 
                              ? Icons.volume_up_rounded 
                              : Icons.volume_off_rounded,
                          onTap: () {
                            _playUISound();
                            gameState.toggleSound();
                          },
                          color: Colors.orange,
                          animationDelay: 600,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 重置游戏按钮
                        MenuButton(
                          text: tr('reset_game', isEnglish),
                          icon: Icons.refresh_rounded,
                          onTap: () {
                            _playUISound();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(tr('reset_confirm_title', isEnglish)),
                                content: Text(tr('reset_confirm_message', isEnglish)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _playUISound();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(tr('cancel', isEnglish)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _playUISound();
                                      gameState.resetProgress();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(tr('confirm', isEnglish)),
                                  ),
                                ],
                              ),
                            );
                          },
                          color: Colors.red,
                          animationDelay: 800,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
              
              // 右上角语言切换按钮
              Positioned(
                top: 10,
                right: 20,
                child: ElevatedButton(
                  onPressed: () {
                    _playUISound();
                    gameState.toggleLanguage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(tr('language', isEnglish)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 主界面Logo绘制
class HomeLogo extends CustomPainter {
  final bool isEnglish;
  
  HomeLogo({required this.isEnglish});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 背景阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    // 使用ID 17关的SVG苹果路径
    final applePath = parseSvgPathData("M 878 697C 873 711 868 725 862 739C 849 770 832 799 814 826C 788 862 767 887 751 901C 727 924 700 936 671 936C 651 936 626 930 597 919C 568 907 542 901 518 901C 492 901 465 907 436 919C 407 930 383 937 365 937C 338 938 310 926 283 901C 266 886 244 860 218 823C 190 784 167 738 149 686C 130 630 120 576 120 523C 120 463 133 411 159 367C 180 332 207 304 241 284C 275 264 312 253 352 253C 374 253 402 259 438 273C 473 286 496 293 506 293C 513 293 538 285 581 269C 621 255 656 249 683 251C 759 257 816 287 854 341C 786 382 753 439 753 513C 754 570 775 618 816 656C 834 674 855 687 878 697 M 688 55C 688 100 672 142 639 181C 600 227 552 254 500 250C 499 245 499 239 499 233C 499 190 518 143 551 106C 568 87 589 71 615 58C 640 45 665 38 688 37C 688 43 688 49 688 55");
    
    // 获取原始路径边界
    final Rect bounds = applePath.getBounds();
    
    // 创建变换矩阵
    final Matrix4 matrix = Matrix4.identity();
    
    // 居中并缩放
    final double scale = size.width / bounds.width * 0.8;
    matrix.translate(
      center.dx - bounds.center.dx * scale, 
      center.dy - bounds.center.dy * scale
    );
    matrix.scale(scale, scale);
    
    // 绘制阴影
    final shadowMatrix = Matrix4.identity();
    shadowMatrix.translate(
      center.dx - bounds.center.dx * scale + 5, 
      center.dy - bounds.center.dy * scale + 5
    );
    shadowMatrix.scale(scale, scale);
    canvas.drawPath(applePath.transform(shadowMatrix.storage), shadowPaint);
    
    // 绘制苹果
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawPath(applePath.transform(matrix.storage), paint);
    
    // 切割线
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // 对角线切割 - 从左上到右下，更整齐，向下移动一点
    final lineStart = Offset(center.dx - size.width * 0.45, center.dy - size.height * 0.35);
    final lineEnd = Offset(center.dx + size.width * 0.45, center.dy + size.height * 0.55);
    canvas.drawLine(lineStart, lineEnd, linePaint);
    
    // 添加一个"完美"标签
    final perfectPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    final radius = size.width * 0.4; // 保留原来的比例计算
    final perfectPath = Path()
      ..moveTo(center.dx + radius * 0.4, center.dy - radius * 0.7)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 0.7)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 0.4)
      ..lineTo(center.dx + radius * 0.4, center.dy - radius * 0.4)
      ..close();
    
    canvas.drawPath(perfectPath, perfectPaint);
    
    const perfectTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
    
    final perfectTextSpan = TextSpan(
      text: tr('perfect', isEnglish),
      style: perfectTextStyle,
    );
    
    final perfectTextPainter = TextPainter(
      text: perfectTextSpan,
      textDirection: TextDirection.ltr,
    );
    
    perfectTextPainter.layout();
    perfectTextPainter.paint(
      canvas,
      Offset(
        center.dx + radius * 0.42,
        center.dy - radius * 0.63,
      ),
    );
    
    // 文字 - 百分比
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
    
    final textSpan1 = TextSpan(
      text: '50%',
      style: textStyle,
    );
    
    final textPainter1 = TextPainter(
      text: textSpan1,
      textDirection: TextDirection.ltr,
    );
    
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset(center.dx - radius * 0.5, center.dy - radius * -0.40),
    );
    
    final textSpan2 = TextSpan(
      text: '50%',
      style: textStyle,
    );
    
    final textPainter2 = TextPainter(
      text: textSpan2,
      textDirection: TextDirection.ltr,
    );
    
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(center.dx + radius * 0.05, center.dy + radius * -0.25),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 