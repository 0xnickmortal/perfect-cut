import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../utils/translations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2秒后导航到主菜单
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isEnglish = gameState.isEnglish;
    
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 游戏Logo - 使用ID 17关的SVG矢量苹果
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: AppleLogoPainter(isEnglish: isEnglish),
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
            ),
            
            const SizedBox(height: 80),
            
            // 游戏标题
            Text(
              tr('app_title', isEnglish),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 300), duration: const Duration(milliseconds: 500)),
          ],
        ),
      ),
    );
  }
}

// Logo自定义绘制器 - 使用ID 17关的被切开的苹果SVG
class AppleLogoPainter extends CustomPainter {
  final bool isEnglish;
  
  AppleLogoPainter({required this.isEnglish});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
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
    
    // 绘制变换后的路径
    canvas.drawPath(applePath.transform(matrix.storage), paint);
    
    // 添加切割线
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // 对角线切割 - 从左上到右下，更居中，向下移动一点
    final lineStart = Offset(center.dx - size.width * 0.45, center.dy - size.height * 0.35);
    final lineEnd = Offset(center.dx + size.width * 0.45, center.dy + size.height * 0.55);
    canvas.drawLine(lineStart, lineEnd, linePaint);
    
    // 添加百分比文字
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    
    // 左上角百分比
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
      Offset(center.dx - size.width * 0.25, center.dy - size.height * -0.1),
    );
    
    // 右下角百分比
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
      Offset(center.dx + size.width * -0.05, center.dy + size.height * -0.15),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 