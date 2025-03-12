import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import '../models/shape.dart';
import '../utils/cut_utils.dart';
import '../utils/offset_extensions.dart';  // 导入Offset扩展
import '../utils/translations.dart';  // 导入翻译工具

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // 切割起点和终点
  Offset? _cutStart;
  Offset? _cutEnd;
  
  // 形状的路径
  Path? _shapePath;
  
  // 切割后的两个部分
  List<Path>? _cutPaths;
  
  // 切割精度
  double _accuracy = 0.0;
  
  // 左右两半的占比
  double _leftPercentage = 0.0;
  double _rightPercentage = 0.0;
  
  // 是否已完成切割
  bool _cutCompleted = false;
  
  // 关卡通过时的星级
  int _stars = 0;
  
  // 是否为完美切割
  bool _isPerfect = false;
  
  // 切割完成后的动画控制器
  late AnimationController _resultAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  
  // 音频播放器
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    // 初始化结果动画控制器
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // 初始化动画
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.elasticOut,
    ));
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutQuad),
    ));
    
    // 初始化形状
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initShape();
    });
  }
  
  @override
  void dispose() {
    _resultAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  // 播放切割声音
  void _playCutSound() async {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('audio/cut.wav'), volume: 0.5);
      } catch (e) {
        // 音频播放失败时的静默处理
        debugPrint('无法播放切割声音: $e');
      }
    }
  }
  
  // 播放完美切割声音
  void _playPerfectSound() async {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource('audio/perfect.wav'), volume: 0.7);
      } catch (e) {
        // 音频播放失败时的静默处理
        debugPrint('无法播放完美声音: $e');
      }
    }
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
  
  void _initShape() {
    final gameState = Provider.of<GameState>(context, listen: false);
    final level = gameState.levels[gameState.currentLevel];
    
    // 获取屏幕中心
    final screenSize = MediaQuery.of(context).size;
    final center = Offset(screenSize.width / 2, screenSize.height * 0.35); // 进一步上移形状的Y轴位置
    
    // 创建形状路径
    setState(() {
      _shapePath = level.shape.getPath(center: center);
      _cutPaths = null;
      _cutCompleted = false;
      _accuracy = 0.0;
      _stars = 0;
      _isPerfect = false;
    });
  }
  
  void _handleCut(Offset start, Offset end) {
    if (_cutCompleted || _shapePath == null) return;
    
    // 计算切割
    final cutPaths = CutUtils.cutShape(_shapePath!, start, end);
    
    // 计算切割精度
    final accuracy = CutUtils.calculateAreaMoreAccurate(cutPaths[0], cutPaths[1]);
    
    // 计算左右两半的面积
    double totalArea = 0;
    
    // 使用更精确的蒙特卡洛方法计算面积
    const int samples = 20000; // 增加样本数量以提高精度
    
    // 获取形状的边界矩形来确定采样区域
    final rect = Rect.fromLTRB(
      min(cutPaths[0].getBounds().left, cutPaths[1].getBounds().left),
      min(cutPaths[0].getBounds().top, cutPaths[1].getBounds().top),
      max(cutPaths[0].getBounds().right, cutPaths[1].getBounds().right),
      max(cutPaths[0].getBounds().bottom, cutPaths[1].getBounds().bottom),
    );
    
    int points1 = 0;
    int points2 = 0;
    final random = Random();
    
    for (int i = 0; i < samples; i++) {
      final point = Offset(
        rect.left + random.nextDouble() * rect.width,
        rect.top + random.nextDouble() * rect.height,
      );
      
      if (cutPaths[0].contains(point)) {
        points1++;
      }
      
      if (cutPaths[1].contains(point)) {
        points2++;
      }
    }
    
    // 计算总采样点数
    totalArea = (points1 + points2).toDouble();
    
    if (totalArea > 0) {
      // 计算百分比
      _leftPercentage = (points1 / totalArea * 100);
      _rightPercentage = (points2 / totalArea * 100);
      
      // 确保百分比和为100%
      final total = _leftPercentage + _rightPercentage;
      if (total != 100) {
        final factor = 100 / total;
        _leftPercentage *= factor;
        _rightPercentage *= factor;
      }
    } else {
      _leftPercentage = 50.0;
      _rightPercentage = 50.0;
    }
    
    // 播放切割声音
    _playCutSound();
    
    // 设置状态
    setState(() {
      _cutPaths = cutPaths;
      _accuracy = accuracy;
      _cutCompleted = true;
      
      // 计算星星数量 - 基于两半的平衡程度
      if (accuracy >= 0.95) { // 使用更低的阈值以适应改进的计算方法
        _stars = 3;
        _isPerfect = true;
        
        // 播放完美切割声音
        Future.delayed(const Duration(milliseconds: 300), () {
          _playPerfectSound();
        });
      } else if (accuracy >= 0.85) {
        _stars = 2;
      } else {
        _stars = 1;
      }
    });
    
    // 显示结果动画
    _resultAnimController.forward(from: 0.0);
    
    // 完成关卡
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.completeLevel(accuracy);
  }
  
  // 重置关卡
  void _resetLevel() {
    setState(() {
      _cutStart = null;
      _cutEnd = null;
      _cutPaths = null;
      _cutCompleted = false;
      _accuracy = 0.0;
      _stars = 0;
      _isPerfect = false;
    });
    
    _initShape();
  }
  
  // 进入下一关
  void _nextLevel() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // 检查是否有下一关
    if (gameState.currentLevel < gameState.levels.length - 1 && 
        gameState.unlockedLevels[gameState.currentLevel + 1]) {
      gameState.setCurrentLevel(gameState.currentLevel + 1);
      _resetLevel();
    } else {
      // 如果没有下一关或下一关未解锁，回到关卡选择
      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final level = gameState.levels[gameState.currentLevel];
    final bool isEnglish = gameState.isEnglish;
    
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          '${tr('level', isEnglish)} ${level.id + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 声音控制
          IconButton(
            icon: Icon(
              gameState.soundEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            tooltip: tr(gameState.soundEnabled ? 'sound_on' : 'sound_off', isEnglish),
            onPressed: () {
              _playUISound();
              gameState.toggleSound();
            },
          ),
          // 重置按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: tr('reset_level', isEnglish),
            onPressed: () {
              _playUISound();
              _resetLevel();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // 当前关卡信息
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20), // 进一步减小垂直内边距
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${tr('level_target', isEnglish)}: ${tr('divide_into', isEnglish)} ${level.requiredSlices} ${tr('equal_parts', isEnglish)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            
            // 准确率显示
            if (_cutCompleted)
              AnimatedBuilder(
                animation: _resultAnimController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), // 减小垂直内边距
                      margin: const EdgeInsets.only(left: 40, right: 40, bottom: 0), // 去掉底部外边距
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${tr('accuracy', isEnglish)}: ${(_accuracy * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isPerfect ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 左右占比显示
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                Text(
                                  tr('cut_ratio', isEnglish),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${tr('left_half', isEnglish)}: ${_leftPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _isPerfect ? Colors.green : Colors.blue.shade700,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      height: 20,
                                      width: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                    Text(
                                      '${tr('right_half', isEnglish)}: ${_rightPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _isPerfect ? Colors.green : Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Icon(
                                index < _stars 
                                    ? Icons.star_rounded 
                                    : Icons.star_border_rounded,
                                color: index < _stars ? Colors.amber : Colors.grey,
                                size: 30,
                              );
                            }),
                          ),
                          if (_isPerfect)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tr('perfect', isEnglish),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
                 
            // 游戏画布
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 20), // 增加底部边距，减少底部区域占比
                alignment: Alignment.center,
                // 增加约束确保形状能够充分展示
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                // 添加内边距，进一步调整内容位置
                padding: const EdgeInsets.only(bottom: 40),
                child: GestureDetector(
                  onPanStart: (details) {
                    if (_cutCompleted) return;
                    
                    setState(() {
                      _cutStart = details.localPosition;
                      _cutEnd = details.localPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    if (_cutCompleted || _cutStart == null) return;
                    
                    setState(() {
                      _cutEnd = details.localPosition;
                    });
                  },
                  onPanEnd: (details) {
                    if (_cutCompleted || _cutStart == null || _cutEnd == null) return;
                    
                    // 确保起点和终点不是同一个点
                    if ((_cutStart! - _cutEnd!).distance > 10.0) {
                      // 切割形状
                      _handleCut(_cutStart!, _cutEnd!);
                    } else {
                      setState(() {
                        _cutStart = null;
                        _cutEnd = null;
                      });
                    }
                  },
                  child: SizedBox.expand(
                    child: CustomPaint(
                      painter: ShapePainter(
                        shapePath: _shapePath,
                        cutPaths: _cutPaths,
                        cutStart: _cutStart,
                        cutEnd: _cutEnd,
                        cutCompleted: _cutCompleted,
                        color: level.shape.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 底部按钮
            if (_cutCompleted)
              AnimatedBuilder(
                animation: _resultAnimController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(15), // 减小按钮区域内边距
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 重试按钮
                            ElevatedButton.icon(
                              onPressed: () {
                                _playUISound();
                                _resetLevel();
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(tr('try_again', isEnglish)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // 下一关按钮
                            ElevatedButton.icon(
                              onPressed: () {
                                _playUISound();
                                _nextLevel();
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: Text(tr('next_level', isEnglish)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            // 如果没有完成切割，显示提示
            if (!_cutCompleted)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(15), // 减小提示区域内边距
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tr('swipe_to_cut', isEnglish),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 自定义画布，绘制形状和切割线
class ShapePainter extends CustomPainter {
  final Path? shapePath;
  final List<Path>? cutPaths;
  final Offset? cutStart;
  final Offset? cutEnd;
  final bool cutCompleted;
  final Color color;
  
  ShapePainter({
    this.shapePath,
    this.cutPaths,
    this.cutStart,
    this.cutEnd,
    this.cutCompleted = false,
    this.color = Colors.blue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (shapePath == null) return;
    
    // 绘制阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    final shadowOffset = const Offset(5, 5);
    
    if (cutCompleted && cutPaths != null && cutPaths!.length == 2) {
      // 计算切割线方向
      Offset cutVector = Offset.zero;
      if (cutStart != null && cutEnd != null) {
        cutVector = (cutEnd! - cutStart!).normalize();
      }
      
      // 对两半进行适当的视觉分离
      final double offset = 10.0; // 进一步减小分离距离，使切割形状更紧凑
      
      // 获取形状的原始中心位置，以便保持整体平衡
      final Rect originalBounds = shapePath!.getBounds();
      final Offset originalCenter = originalBounds.center;
      
      // 根据切割方向计算偏移
      // 更偏向水平切割时
      if (cutVector.dx.abs() > cutVector.dy.abs()) {
        // 如果更接近水平切割，则上下分离
        final halfUp = cutPaths![0];
        final halfDown = cutPaths![1];
        
        // 绘制上半部分及阴影
        canvas.save();
        canvas.translate(0, -offset/2); // 仅移动一半的距离，保持整体平衡
        
        // 阴影
        canvas.save();
        canvas.translate(shadowOffset.dx, shadowOffset.dy);
        canvas.drawPath(halfUp, shadowPaint);
        canvas.restore();
        
        // 形状
        final shapePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(halfUp, shapePaint);
        
        // 边框
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(halfUp, borderPaint);
        canvas.restore();
        
        // 绘制下半部分及阴影
        canvas.save();
        canvas.translate(0, offset/2); // 仅移动一半的距离，保持整体平衡
        
        // 阴影
        canvas.save();
        canvas.translate(shadowOffset.dx, shadowOffset.dy);
        canvas.drawPath(halfDown, shadowPaint);
        canvas.restore();
        
        // 形状
        canvas.drawPath(halfDown, shapePaint);
        canvas.drawPath(halfDown, borderPaint);
        canvas.restore();
      } else {
        // 如果更接近垂直切割，则左右分离
        final halfLeft = cutPaths![0];
        final halfRight = cutPaths![1];
        
        // 绘制左半部分及阴影
        canvas.save();
        canvas.translate(-offset/2, 0); // 仅移动一半的距离，保持整体平衡
        
        // 阴影
        canvas.save();
        canvas.translate(shadowOffset.dx, shadowOffset.dy);
        canvas.drawPath(halfLeft, shadowPaint);
        canvas.restore();
        
        // 形状
        final shapePaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(halfLeft, shapePaint);
        
        // 边框
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawPath(halfLeft, borderPaint);
        canvas.restore();
        
        // 绘制右半部分及阴影
        canvas.save();
        canvas.translate(offset/2, 0); // 仅移动一半的距离，保持整体平衡
        
        // 阴影
        canvas.save();
        canvas.translate(shadowOffset.dx, shadowOffset.dy);
        canvas.drawPath(halfRight, shadowPaint);
        canvas.restore();
        
        // 形状
        canvas.drawPath(halfRight, shapePaint);
        canvas.drawPath(halfRight, borderPaint);
        canvas.restore();
      }
    } else {
      // 绘制未切割的形状
      // 阴影
      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawPath(shapePath!, shadowPaint);
      canvas.restore();
      
      // 形状填充
      final shapePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(shapePath!, shapePaint);
      
      // 形状描边
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawPath(shapePath!, borderPaint);
    }
    
    // 如果正在拖动，绘制切割线
    if (cutStart != null && cutEnd != null && !cutCompleted) {
      final linePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(cutStart!, cutEnd!, linePaint);
      
      // 绘制起点和终点
      final pointPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(cutStart!, 5, pointPaint);
      canvas.drawCircle(cutEnd!, 5, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) {
    return oldDelegate.shapePath != shapePath ||
           oldDelegate.cutPaths != cutPaths ||
           oldDelegate.cutStart != cutStart ||
           oldDelegate.cutEnd != cutEnd ||
           oldDelegate.cutCompleted != cutCompleted;
  }
} 