import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    
    // Web版本特定的尺寸调整
    final logoSize = kIsWeb 
        ? screenSize.width * 0.4 // Web版本减小Logo尺寸
        : screenSize.width * 0.6;
    
    // Web版本特定的内边距调整    
    final horizontalPadding = kIsWeb 
        ? EdgeInsets.symmetric(horizontal: screenSize.width * 0.2) // Web版本增大侧边距
        : const EdgeInsets.symmetric(horizontal: 40);
    
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
                      child: kIsWeb
                          // Web版本的Logo使用不同的尺寸和布局约束
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: logoSize,
                                maxHeight: logoSize,
                              ),
                              child: CustomPaint(
                                painter: HomeLogo(isEnglish: isEnglish),
                              ),
                            )
                          // 移动版本的原始Logo
                          : SizedBox(
                              width: logoSize,
                              height: logoSize,
                              child: CustomPaint(
                                painter: HomeLogo(isEnglish: isEnglish),
                              ),
                            ),
                    )
                    .animate()
                    .scale(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                    ),
                  ),
                  
                  // 菜单按钮
                  Padding(
                    padding: horizontalPadding,
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
                  
                  // 调整底部空间，在Web版本上增加更多
                  SizedBox(height: kIsWeb ? 60 : 40),
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
    final radius = size.width * 0.4;
    
    // Web版本使用简化的苹果形状
    if (kIsWeb) {
      _drawSimpleApple(canvas, center, size);
    } else {
      _drawSvgApple(canvas, center, size);
    }
    
    // 切割线
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Web版本特定的切割线位置调整
    final lineStartOffset = kIsWeb 
        ? Offset(center.dx - size.width * 0.4, center.dy - size.height * 0.1) 
        : Offset(center.dx - size.width * 0.45, center.dy - size.height * 0.35);
    final lineEndOffset = kIsWeb 
        ? Offset(center.dx + size.width * 0.4, center.dy + size.height * 0.3) 
        : Offset(center.dx + size.width * 0.45, center.dy + size.height * 0.55);
    
    canvas.drawLine(lineStartOffset, lineEndOffset, linePaint);
    
    // 添加一个"完美"标签 - Web版本调整位置
    final perfectPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    // Web版本特定的"完美"标签位置调整
    final perfectXOffset = kIsWeb ? 0.2 : 0.4;
    final perfectYOffset = kIsWeb ? 0.4 : 0.7;
    
    final perfectPath = Path()
      ..moveTo(center.dx + radius * perfectXOffset, center.dy - radius * perfectYOffset)
      ..lineTo(center.dx + radius * (perfectXOffset + 0.3), center.dy - radius * perfectYOffset)
      ..lineTo(center.dx + radius * (perfectXOffset + 0.3), center.dy - radius * (perfectYOffset - 0.3))
      ..lineTo(center.dx + radius * perfectXOffset, center.dy - radius * (perfectYOffset - 0.3))
      ..close();
    
    canvas.drawPath(perfectPath, perfectPaint);
    
    // 文字大小调整
    final perfectTextStyle = TextStyle(
      color: Colors.white,
      fontSize: kIsWeb ? 16 : 14, // Web版本字体大小稍大
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
        center.dx + radius * (perfectXOffset + 0.02),
        center.dy - radius * (perfectYOffset - 0.07),
      ),
    );
    
    // 百分比文字 - Web版本调整位置
    final percentTextStyle = TextStyle(
      color: Colors.white,
      fontSize: kIsWeb ? 28 : 25, // Web版本字体大小稍大
      fontWeight: FontWeight.bold,
    );
    
    // Web版本特定的百分比位置调整
    final percent1XOffset = kIsWeb ? -0.2 : -0.5;
    final percent1YOffset = kIsWeb ? 0.25 : -0.40;
    final percent2XOffset = kIsWeb ? 0.0 : 0.05;
    final percent2YOffset = kIsWeb ? -0.05 : -0.25;
    
    final textSpan1 = TextSpan(
      text: '50%',
      style: percentTextStyle,
    );
    
    final textPainter1 = TextPainter(
      text: textSpan1,
      textDirection: TextDirection.ltr,
    );
    
    textPainter1.layout();
    textPainter1.paint(
      canvas,
      Offset(center.dx + radius * percent1XOffset, center.dy + radius * percent1YOffset),
    );
    
    final textSpan2 = TextSpan(
      text: '50%',
      style: percentTextStyle,
    );
    
    final textPainter2 = TextPainter(
      text: textSpan2,
      textDirection: TextDirection.ltr,
    );
    
    textPainter2.layout();
    textPainter2.paint(
      canvas,
      Offset(center.dx + radius * percent2XOffset, center.dy + radius * percent2YOffset),
    );
  }
  
  // 使用SVG路径绘制复杂的苹果形状（原始版本，用于非Web平台）
  void _drawSvgApple(Canvas canvas, Offset center, Size size) {
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
    
    // 缩放和位置调整
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
  }
  
  // 使用简单形状绘制苹果（Web版本）
  void _drawSimpleApple(Canvas canvas, Offset center, Size size) {
    final appleRadius = size.width * 0.35;
    
    // 绘制苹果的阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(
      Offset(center.dx + 5, center.dy + 5), 
      appleRadius, 
      shadowPaint
    );
    
    // 绘制苹果主体（圆形）
    final applePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, appleRadius, applePaint);
    
    // 添加苹果顶部的凹槽
    final notchPath = Path()
      ..moveTo(center.dx - appleRadius * 0.2, center.dy - appleRadius * 0.9)
      ..quadraticBezierTo(
        center.dx, center.dy - appleRadius * 1.2,
        center.dx + appleRadius * 0.2, center.dy - appleRadius * 0.9
      )
      ..quadraticBezierTo(
        center.dx, center.dy - appleRadius * 0.7,
        center.dx - appleRadius * 0.2, center.dy - appleRadius * 0.9
      )
      ..close();
    
    canvas.drawPath(notchPath, applePaint);
    
    // 添加苹果叶子
    final leafPath = Path()
      ..moveTo(center.dx + appleRadius * 0.1, center.dy - appleRadius * 0.9)
      ..quadraticBezierTo(
        center.dx + appleRadius * 0.3, center.dy - appleRadius * 1.3,
        center.dx + appleRadius * 0.4, center.dy - appleRadius * 0.9
      )
      ..quadraticBezierTo(
        center.dx + appleRadius * 0.3, center.dy - appleRadius * 1.0,
        center.dx + appleRadius * 0.1, center.dy - appleRadius * 0.9
      )
      ..close();
    
    final leafPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 