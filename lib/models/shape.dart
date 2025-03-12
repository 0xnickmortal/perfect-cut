import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

enum ShapeType {
  rectangle,
  circle,
  triangle,
  oval,
  star,
  polygon,
  apple,       // 苹果形状
  watermelon,  // 西瓜形状
  heart,       // 心形
  cloud,       // 云形
  leaf,        // 叶子
  drop,        // 水滴
  diamond,     // 钻石
  custom,      // 自定义路径
  svg,         // SVG路径
}

class GameShape {
  final ShapeType type;
  final double width;
  final double height;
  final double radius;
  final int sides;       // 多边形边数
  final double size;     // 常规形状的大小
  final Color color;
  final Path? customPath;  // 自定义路径
  final bool isHalf;       // 是否为一半形状（如半个西瓜）
  
  GameShape._({
    required this.type,
    this.width = 0,
    this.height = 0,
    this.radius = 0,
    this.sides = 0,
    this.size = 0,
    this.color = Colors.blue,
    this.customPath,
    this.isHalf = false,
  });
  
  // 矩形工厂构造函数
  factory GameShape.rectangle({
    required double width,
    required double height,
    Color color = Colors.blue,
  }) {
    return GameShape._(
      type: ShapeType.rectangle,
      width: width,
      height: height,
      color: color,
    );
  }
  
  // 圆形工厂构造函数
  factory GameShape.circle({
    required double radius,
    Color color = Colors.green,
  }) {
    return GameShape._(
      type: ShapeType.circle,
      radius: radius,
      color: color,
    );
  }
  
  // 三角形工厂构造函数
  factory GameShape.triangle({
    required double size,
    Color color = Colors.orange,
  }) {
    return GameShape._(
      type: ShapeType.triangle,
      size: size,
      color: color,
    );
  }
  
  // 椭圆形工厂构造函数
  factory GameShape.oval({
    required double width,
    required double height,
    Color color = Colors.purple,
  }) {
    return GameShape._(
      type: ShapeType.oval,
      width: width,
      height: height,
      color: color,
    );
  }
  
  // 星形工厂构造函数
  factory GameShape.star({
    required double size,
    int points = 5,
    Color color = Colors.yellow,
  }) {
    return GameShape._(
      type: ShapeType.star,
      size: size,
      sides: points,
      color: color,
    );
  }
  
  // 正多边形工厂构造函数
  factory GameShape.polygon({
    required double radius,
    required int sides,
    Color color = Colors.teal,
  }) {
    return GameShape._(
      type: ShapeType.polygon,
      radius: radius,
      sides: sides,
      color: color,
    );
  }
  
  // 苹果形状工厂构造函数
  factory GameShape.apple({
    required double size,
    Color color = Colors.red,
  }) {
    return GameShape._(
      type: ShapeType.apple,
      size: size,
      color: color,
    );
  }
  
  // 西瓜形状工厂构造函数
  factory GameShape.watermelon({
    required double size,
    bool isHalf = true,  // 默认为半个西瓜
    Color color = Colors.green,
  }) {
    return GameShape._(
      type: ShapeType.watermelon,
      size: size,
      color: color,
      isHalf: isHalf,
    );
  }
  
  // 心形工厂构造函数
  factory GameShape.heart({
    required double size,
    Color color = Colors.red,
  }) {
    return GameShape._(
      type: ShapeType.heart,
      size: size,
      color: color,
    );
  }
  
  // 云形工厂构造函数
  factory GameShape.cloud({
    required double width,
    required double height,
    Color? color,
  }) {
    return GameShape._(
      type: ShapeType.cloud,
      width: width,
      height: height,
      color: color ?? Colors.lightBlue,
    );
  }
  
  // 叶子形工厂构造函数
  factory GameShape.leaf({
    required double size,
    Color color = Colors.green,
  }) {
    return GameShape._(
      type: ShapeType.leaf,
      size: size,
      color: color,
    );
  }
  
  // 水滴形状工厂构造函数
  factory GameShape.drop({
    required double size,
    Color? color,
  }) {
    return GameShape._(
      type: ShapeType.drop,
      size: size,
      color: color ?? Colors.blue,
    );
  }
  
  // 钻石形状工厂构造函数
  factory GameShape.diamond({
    required double size,
    Color? color,
  }) {
    return GameShape._(
      type: ShapeType.diamond,
      size: size,
      color: color ?? Colors.blue,
    );
  }
  
  // 自定义形状工厂构造函数
  factory GameShape.custom({
    required Path path,
    Color color = Colors.red,
  }) {
    return GameShape._(
      type: ShapeType.custom,
      customPath: path,
      color: color,
    );
  }
  
  // SVG路径工厂构造函数
  factory GameShape.fromSvg({
    required String svgPath,
    required double width, 
    required double height,
    Color color = Colors.red,
  }) {
    // 解析SVG路径数据为Path对象
    final Path path = parseSvgPathData(svgPath);
    
    // 获取原始路径边界
    final Rect bounds = path.getBounds();
    
    // 创建一个新路径用于变换
    final Path normalizedPath = Path();
    
    // 创建变换矩阵 - 先缩小坐标范围
    final Matrix4 normalizeMatrix = Matrix4.identity();
    normalizeMatrix.scale(0.001, 0.001);  // 将大坐标数值缩小1000倍
    
    // 将大坐标数值的路径转换为小坐标数值
    normalizedPath.addPath(path.transform(normalizeMatrix.storage), Offset.zero);
    
    return GameShape._(
      type: ShapeType.svg,
      width: width,
      height: height,
      color: color,
      customPath: normalizedPath,
    );
  }
  
  // 获取形状的路径
  Path getPath({Offset center = Offset.zero}) {
    switch (type) {
      case ShapeType.rectangle:
        return Path()
          ..addRect(Rect.fromCenter(
            center: center,
            width: width,
            height: height,
          ));
      
      case ShapeType.circle:
        return Path()
          ..addOval(Rect.fromCircle(
            center: center,
            radius: radius,
          ));
      
      case ShapeType.triangle:
        final path = Path();
        final height = size * sqrt(3) / 2;
        path.moveTo(center.dx, center.dy - height / 2);
        path.lineTo(center.dx - size / 2, center.dy + height / 2);
        path.lineTo(center.dx + size / 2, center.dy + height / 2);
        path.close();
        return path;
      
      case ShapeType.oval:
        return Path()
          ..addOval(Rect.fromCenter(
            center: center,
            width: width,
            height: height,
          ));
      
      case ShapeType.star:
        return _createStarPath(center, size, sides);
      
      case ShapeType.polygon:
        return _createPolygonPath(center, radius, sides);
      
      case ShapeType.apple:
        return _createApplePath(center, size);
      
      case ShapeType.watermelon:
        return _createWatermelonPath(center, size, isHalf);
      
      case ShapeType.heart:
        return _createHeartPath(center, size);
      
      case ShapeType.cloud:
        return _createCloudPath(center, width, height);
      
      case ShapeType.leaf:
        return _createLeafPath(center, size);
      
      case ShapeType.drop:
        return _createDropPath(center, size);
        
      case ShapeType.diamond:
        return _createDiamondPath(center, size);
      
      case ShapeType.custom:
        if (customPath != null) {
          final Matrix4 matrix = Matrix4.identity();
          matrix.translate(center.dx, center.dy);
          return customPath!.transform(matrix.storage);
        }
        return Path()..addRect(Rect.fromCenter(
          center: center,
          width: 100,
          height: 100,
        ));
      
      case ShapeType.svg:
        if (customPath != null) {
          // 创建变换矩阵
          final Matrix4 matrix = Matrix4.identity();
          
          // 使用明确的偏移量调整SVG位置
          // 默认偏移量
          double horizontalOffset = -width * 0.5;
          double verticalOffset = -height * 0.5;
          
          // 根据形状大小和颜色识别不同的SVG图形并应用特殊偏移
          
          // SVG矢量苹果，宽高为240，颜色为红色
          if (width == 240 && height == 240 && 
              (color == Colors.red || color.value == 0xFFFF0000)) {
            horizontalOffset = -width * 0.5;  // 标准水平居中
            verticalOffset = -height * 0.5;   // 标准垂直居中
          }
          
          // 香蕉，宽高为450，颜色为香蕉黄
          else if (width == 450 && height == 450 && 
              (color == const Color(0xFFF7C562) || color.value == 0xFFF7C562)) {
            horizontalOffset = -width * 0.1;  // 向右偏移一些
            verticalOffset = -height * 0.2;  // 稍微向上偏移
          }
          
          // 咖啡杯，宽450高360，颜色为咖啡棕
          else if (width == 450 && height == 360 && 
              (color == const Color(0xFF8D6E63) || color.value == 0xFF8D6E63)) {
            horizontalOffset = -width * 0.1;  // 偏右一些
            verticalOffset = -height * 0.2;   // 偏上一些
          }
          
          // 汽车，宽650高500，颜色为汽车红
          else if (width == 650 && height == 500 && 
              (color == const Color(0xFFE53935) || color.value == 0xFFE53935)) {
            horizontalOffset = -width * 0.1;  // 保持较居中
            verticalOffset = -height * 0.2;    // 标准垂直居中
          }
          
          // 香蕉旧尺寸的特殊处理，兼容旧代码
          else if (width == 300 && height == 300 && 
              (color == const Color(0xFFF7C562) || color.value == 0xFFF7C562)) {
            horizontalOffset = -width * 0.1;  // 减少向左的偏移，实现向右移动
            verticalOffset = -height * 0.3;   // 稍微下移一点
          }
          
          // 应用水平和垂直偏移
          matrix.translate(center.dx + horizontalOffset, center.dy + verticalOffset);
          
          // 然后应用缩放
          final double scaleFactor = min(width, height) * 1;
          matrix.scale(scaleFactor, scaleFactor);
          
          return customPath!.transform(matrix.storage);
        }
        return Path()..addRect(Rect.fromCenter(
          center: center,
          width: 100,
          height: 100,
        ));
    }
  }
  
  // 创建星形路径
  Path _createStarPath(Offset center, double size, int points) {
    final path = Path();
    final outerRadius = size / 2;
    final innerRadius = outerRadius * 0.4;
    final double centerX = center.dx;
    final double centerY = center.dy;
    
    final double slice = 2 * pi / points;
    
    for (int i = 0; i < points; i++) {
      final double angle = i * slice - pi / 2;
      final double nextAngle = angle + slice / 2;
      
      final double outerX = centerX + outerRadius * cos(angle);
      final double outerY = centerY + outerRadius * sin(angle);
      
      final double innerX = centerX + innerRadius * cos(nextAngle);
      final double innerY = centerY + innerRadius * sin(nextAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    return path;
  }
  
  // 创建正多边形路径
  Path _createPolygonPath(Offset center, double radius, int sides) {
    final path = Path();
    final double centerX = center.dx;
    final double centerY = center.dy;
    
    final double slice = 2 * pi / sides;
    
    for (int i = 0; i < sides; i++) {
      final double angle = i * slice - pi / 2;
      final double x = centerX + radius * cos(angle);
      final double y = centerY + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    return path;
  }
  
  // 创建苹果形状路径
  Path _createApplePath(Offset center, double size) {
    final path = Path();
    final double r = size / 2;  // 基础半径
    
    // 苹果主体
    path.moveTo(center.dx, center.dy - r * 0.8);
    
    // 右侧曲线
    path.cubicTo(
      center.dx + r * 0.8, center.dy - r * 0.8,  // 控制点1
      center.dx + r, center.dy,                // 控制点2
      center.dx, center.dy + r                 // 终点
    );
    
    // 左侧曲线
    path.cubicTo(
      center.dx - r, center.dy,                // 控制点1
      center.dx - r * 0.8, center.dy - r * 0.8,  // 控制点2
      center.dx, center.dy - r * 0.8            // 起点
    );
    
    // 苹果顶部凹陷
    path.moveTo(center.dx, center.dy - r * 0.8);
    path.quadraticBezierTo(
      center.dx, center.dy - r * 1.2,  // 控制点
      center.dx - r * 0.2, center.dy - r * 1.0  // 终点
    );
    
    // 苹果柄
    final stemPath = Path();
    stemPath.moveTo(center.dx - r * 0.1, center.dy - r * 1.0);
    stemPath.quadraticBezierTo(
      center.dx - r * 0.05, center.dy - r * 1.4,  // 控制点
      center.dx + r * 0.1, center.dy - r * 1.3  // 终点
    );
    
    path.addPath(stemPath, Offset.zero);
    
    // 苹果叶子
    final leafPath = Path();
    leafPath.moveTo(center.dx + r * 0.1, center.dy - r * 1.3);
    leafPath.quadraticBezierTo(
      center.dx + r * 0.4, center.dy - r * 1.5,  // 控制点
      center.dx + r * 0.3, center.dy - r * 1.2  // 终点
    );
    leafPath.quadraticBezierTo(
      center.dx + r * 0.2, center.dy - r * 1.1,  // 控制点
      center.dx + r * 0.1, center.dy - r * 1.3  // 起点
    );
    
    path.addPath(leafPath, Offset.zero);
    
    return path;
  }
  
  // 创建西瓜形状路径
  Path _createWatermelonPath(Offset center, double size, bool isHalf) {
    final path = Path();
    
    if (isHalf) {
      // 半个西瓜
      path.addArc(
        Rect.fromCenter(center: center, width: size, height: size),
        0, // 开始角度
        pi, // 结束角度（半圆）
      );
      path.lineTo(center.dx - size / 2, center.dy);
      path.close();
      
      // 可以添加一些西瓜籽
      final seedPath = Path();
      final seedSize = size * 0.05;
      final random = Random(42); // 固定随机种子
      
      for (int i = 0; i < 10; i++) {
        final seedX = center.dx - size * 0.45 + random.nextDouble() * size * 0.9;
        final seedY = center.dy - size * 0.4 + random.nextDouble() * size * 0.3;
        
        seedPath.addOval(Rect.fromCenter(
          center: Offset(seedX, seedY),
          width: seedSize,
          height: seedSize * 1.5,
        ));
      }
      
      // 西瓜皮
      final rindPath = Path();
      rindPath.addArc(
        Rect.fromCenter(center: center, width: size * 1.02, height: size * 1.02),
        0,
        pi,
      );
      rindPath.lineTo(center.dx - size / 2, center.dy);
      rindPath.close();
      
      return Path.combine(PathOperation.difference, rindPath, path);
    } else {
      // 整个西瓜
      path.addOval(Rect.fromCenter(
        center: center,
        width: size,
        height: size,
      ));
      
      return path;
    }
  }
  
  // 创建心形路径
  Path _createHeartPath(Offset center, double size) {
    final path = Path();
    final width = size;
    final height = size;
    
    path.moveTo(center.dx, center.dy + height * 0.35);
    
    // 左半边
    path.cubicTo(
      center.dx - width * 0.25, center.dy + height * 0.15,
      center.dx - width * 0.5, center.dy - height * 0.3,
      center.dx, center.dy - height * 0.5
    );
    
    // 右半边
    path.cubicTo(
      center.dx + width * 0.5, center.dy - height * 0.3,
      center.dx + width * 0.25, center.dy + height * 0.15,
      center.dx, center.dy + height * 0.35
    );
    
    path.close();
    return path;
  }
  
  // 创建云形路径
  Path _createCloudPath(Offset center, double width, double height) {
    final path = Path();
    final double r1 = height * 0.5; // 大圆半径
    final double r2 = height * 0.3; // 小圆半径
    
    // 主体大圆
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy),
      width: r1 * 2,
      height: r1 * 2,
    ));
    
    // 左侧圆
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx - r1 * 0.8, center.dy),
      width: r2 * 2,
      height: r2 * 2,
    ));
    
    // 右侧圆
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx + r1 * 0.8, center.dy),
      width: r2 * 2,
      height: r2 * 2,
    ));
    
    // 顶部圆
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy - r1 * 0.7),
      width: r2 * 1.8,
      height: r2 * 1.8,
    ));
    
    return path;
  }
  
  // 创建叶子形状路径
  Path _createLeafPath(Offset center, double size) {
    final path = Path();
    
    path.moveTo(center.dx, center.dy + size / 2); // 底部尖端
    
    // 右侧曲线
    path.cubicTo(
      center.dx + size * 0.4, center.dy + size * 0.3,
      center.dx + size * 0.5, center.dy,
      center.dx, center.dy - size / 2
    );
    
    // 左侧曲线
    path.cubicTo(
      center.dx - size * 0.5, center.dy,
      center.dx - size * 0.4, center.dy + size * 0.3,
      center.dx, center.dy + size / 2
    );
    
    path.close();
    
    // 添加叶脉
    final veinsPath = Path();
    veinsPath.moveTo(center.dx, center.dy + size / 2);
    veinsPath.lineTo(center.dx, center.dy - size / 2);
    
    // 添加侧脉
    for (int i = 1; i <= 3; i++) {
      final y = center.dy - size * 0.3 + i * size * 0.15;
      
      // 右侧
      veinsPath.moveTo(center.dx, y);
      veinsPath.quadraticBezierTo(
        center.dx + size * 0.15, y + size * 0.05,
        center.dx + size * 0.3, y
      );
      
      // 左侧
      veinsPath.moveTo(center.dx, y);
      veinsPath.quadraticBezierTo(
        center.dx - size * 0.15, y + size * 0.05,
        center.dx - size * 0.3, y
      );
    }
    
    return path;
  }
  
  // 创建水滴形状路径
  Path _createDropPath(Offset center, double size) {
    final path = Path();
    
    // 水滴底部圆形部分
    path.addOval(Rect.fromCenter(
      center: Offset(center.dx, center.dy + size * 0.2),
      width: size * 0.8,
      height: size * 0.8,
    ));
    
    // 水滴尖端
    path.moveTo(center.dx - size * 0.4, center.dy + size * 0.2);
    path.quadraticBezierTo(
      center.dx, center.dy - size * 0.8,
      center.dx + size * 0.4, center.dy + size * 0.2
    );
    
    return path;
  }
  
  // 创建钻石形状路径
  Path _createDiamondPath(Offset center, double size) {
    final path = Path();
    
    // 钻石是一个八边形，但上下尖
    path.moveTo(center.dx, center.dy - size / 2); // 顶点
    
    // 右上
    path.lineTo(center.dx + size * 0.4, center.dy - size * 0.2);
    
    // 右侧
    path.lineTo(center.dx + size / 2, center.dy);
    
    // 右下
    path.lineTo(center.dx + size * 0.4, center.dy + size * 0.2);
    
    // 底部
    path.lineTo(center.dx, center.dy + size / 2);
    
    // 左下
    path.lineTo(center.dx - size * 0.4, center.dy + size * 0.2);
    
    // 左侧
    path.lineTo(center.dx - size / 2, center.dy);
    
    // 左上
    path.lineTo(center.dx - size * 0.4, center.dy - size * 0.2);
    
    path.close();
    
    return path;
  }
  
  // 计算形状面积的近似值（用于判断切割后的分割是否相等）
  double calculateArea() {
    switch (type) {
      case ShapeType.rectangle:
        return width * height;
      
      case ShapeType.circle:
        return pi * radius * radius;
      
      case ShapeType.triangle:
        final height = size * sqrt(3) / 2;
        return (size * height) / 2;
      
      case ShapeType.oval:
        return pi * width * height / 4;
      
      case ShapeType.star:
      case ShapeType.polygon:
      case ShapeType.apple:
      case ShapeType.watermelon:
      case ShapeType.heart:
      case ShapeType.cloud:
      case ShapeType.leaf:
      case ShapeType.drop:
      case ShapeType.diamond:
      case ShapeType.custom:
      case ShapeType.svg:
        // 对于复杂形状，我们使用边界矩形面积作为近似
        final path = getPath();
        final rect = path.getBounds();
        return rect.width * rect.height;
    }
  }
} 