import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/shape.dart';
import 'offset_extensions.dart';  // 导入Offset扩展

class CutUtils {
  // 根据起点和终点创建切割线
  static Path createCutLine(Offset start, Offset end, {double thickness = 2.0}) {
    final path = Path();
    final direction = (end - start).normalize();
    final perpendicular = Offset(-direction.dy, direction.dx) * thickness / 2;
    
    path.moveTo(start.dx + perpendicular.dx, start.dy + perpendicular.dy);
    path.lineTo(end.dx + perpendicular.dx, end.dy + perpendicular.dy);
    path.lineTo(end.dx - perpendicular.dx, end.dy - perpendicular.dy);
    path.lineTo(start.dx - perpendicular.dx, start.dy - perpendicular.dy);
    path.close();
    
    return path;
  }
  
  // 使用切割线切割形状，返回两个新的路径
  static List<Path> cutShape(Path shapePath, Offset start, Offset end) {
    // 创建足够长的切割线
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance <= 0) {
      // 防止距离为0导致的错误
      return [shapePath, Path()];
    }
    
    // 延长切割线，确保它穿过整个形状
    final extendFactor = 5000.0 / distance; // 确保更长的距离，完全穿过形状
    final extendedStart = Offset(
      start.dx - dx * extendFactor,
      start.dy - dy * extendFactor,
    );
    final extendedEnd = Offset(
      end.dx + dx * extendFactor,
      end.dy + dy * extendFactor,
    );
    
    try {
      // 使用clipPath方法来切割形状（这比Path.combine更可靠）
      // 创建裁剪路径 - 从切割线的一侧到屏幕的一侧
      final clipPath = Path();
      
      // 切割方向垂直向量
      final dirY = (end.dx - start.dx);
      final dirX = -(end.dy - start.dy);
      
      // 规范化为单位向量
      final mag = sqrt(dirX * dirX + dirY * dirY);
      if (mag <= 0) {
        return [shapePath, Path()]; // 防止除以零
      }
      
      final normX = dirX / mag;
      final normY = dirY / mag;
      
      // 创建裁剪路径：从切割线延伸到屏幕边缘
      clipPath.moveTo(extendedStart.dx, extendedStart.dy);
      clipPath.lineTo(extendedEnd.dx, extendedEnd.dy);
      
      // 向一侧扩展到足够远的距离
      final farDistance = 10000.0;
      clipPath.lineTo(
        extendedEnd.dx + normX * farDistance,
        extendedEnd.dy + normY * farDistance,
      );
      clipPath.lineTo(
        extendedStart.dx + normX * farDistance,
        extendedStart.dy + normY * farDistance,
      );
      clipPath.close();
      
      // 创建两个半部分
      var firstHalf = Path()..addPath(shapePath, Offset.zero);
      firstHalf.fillType = PathFillType.nonZero;
      
      var secondHalf = Path()..addPath(shapePath, Offset.zero);
      secondHalf.fillType = PathFillType.nonZero;
      
      // 用裁剪路径和它的反向裁剪两个半部分
      firstHalf = Path.combine(PathOperation.intersect, firstHalf, clipPath);
      
      // 反向裁剪路径
      final reverseClipPath = Path();
      reverseClipPath.moveTo(extendedStart.dx, extendedStart.dy);
      reverseClipPath.lineTo(extendedEnd.dx, extendedEnd.dy);
      reverseClipPath.lineTo(
        extendedEnd.dx - normX * farDistance,
        extendedEnd.dy - normY * farDistance,
      );
      reverseClipPath.lineTo(
        extendedStart.dx - normX * farDistance,
        extendedStart.dy - normY * farDistance,
      );
      reverseClipPath.close();
      
      secondHalf = Path.combine(PathOperation.intersect, secondHalf, reverseClipPath);
      
      // 检查切割是否成功
      if (firstHalf.getBounds().isEmpty || secondHalf.getBounds().isEmpty) {
        debugPrint('裁剪产生了空路径，尝试备用方法');
        throw Exception("Empty path after clipping");
      }
      
      // 根据切割方向确定左右或上下
      if (dx.abs() > dy.abs()) {
        // 水平切割 - 比较y坐标来确定上下
        final firstCenter = firstHalf.getBounds().center;
        final secondCenter = secondHalf.getBounds().center;
        
        if (firstCenter.dy < secondCenter.dy) {
          return [firstHalf, secondHalf]; // 上半部分在前
        } else {
          return [secondHalf, firstHalf]; // 下半部分在前
        }
      } else {
        // 垂直切割 - 比较x坐标来确定左右
        final firstCenter = firstHalf.getBounds().center;
        final secondCenter = secondHalf.getBounds().center;
        
        if (firstCenter.dx < secondCenter.dx) {
          return [firstHalf, secondHalf]; // 左半部分在前
        } else {
          return [secondHalf, firstHalf]; // 右半部分在前
        }
      }
    } catch (e) {
      debugPrint('直接裁剪方法失败: $e');
      
      // 备用方法：使用Path.combine
      try {
        // 创建一个非常窄的切割线
        final strokeWidth = 0.01; 
        final perpVector = Offset(-dy, dx).normalize() * strokeWidth;
        final cutStroke = Path();
        
        cutStroke.moveTo(extendedStart.dx + perpVector.dx, extendedStart.dy + perpVector.dy);
        cutStroke.lineTo(extendedEnd.dx + perpVector.dx, extendedEnd.dy + perpVector.dy);
        cutStroke.lineTo(extendedEnd.dx - perpVector.dx, extendedEnd.dy - perpVector.dy);
        cutStroke.lineTo(extendedStart.dx - perpVector.dx, extendedStart.dy - perpVector.dy);
        cutStroke.close();
        
        // 尝试两种切割操作
        final leftHalf = Path.combine(PathOperation.difference, shapePath, cutStroke);
        final rightHalf = Path.combine(PathOperation.difference, shapePath, leftHalf);
        
        if (!leftHalf.getBounds().isEmpty && !rightHalf.getBounds().isEmpty) {
          // 根据切割方向确定返回顺序
          if (dx.abs() > dy.abs()) {
            // 水平切割
            final leftCenter = leftHalf.getBounds().center;
            final rightCenter = rightHalf.getBounds().center;
            
            if (leftCenter.dy < rightCenter.dy) {
              return [leftHalf, rightHalf];
            } else {
              return [rightHalf, leftHalf];
            }
          } else {
            // 垂直切割
            final leftCenter = leftHalf.getBounds().center;
            final rightCenter = rightHalf.getBounds().center;
            
            if (leftCenter.dx < rightCenter.dx) {
              return [leftHalf, rightHalf];
            } else {
              return [rightHalf, leftHalf];
            }
          }
        }
      } catch (e2) {
        debugPrint('备用切割方法也失败: $e2');
      }
    }
    
    // 如果所有方法都失败，创建两个近似相等的形状
    // 简单地基于切割方向创建两个矩形区域
    try {
      final bounds = shapePath.getBounds();
      final firstHalf = Path();
      final secondHalf = Path();
      
      if (dx.abs() > dy.abs()) {
        // 水平切割 - 上下分
        final cutY = (start.dy + end.dy) / 2;
        firstHalf.addRect(Rect.fromLTRB(bounds.left, bounds.top, bounds.right, cutY));
        secondHalf.addRect(Rect.fromLTRB(bounds.left, cutY, bounds.right, bounds.bottom));
      } else {
        // 垂直切割 - 左右分
        final cutX = (start.dx + end.dx) / 2;
        firstHalf.addRect(Rect.fromLTRB(bounds.left, bounds.top, cutX, bounds.bottom));
        secondHalf.addRect(Rect.fromLTRB(cutX, bounds.top, bounds.right, bounds.bottom));
      }
      
      // 和原始形状相交以获得实际形状
      final actualFirst = Path.combine(PathOperation.intersect, shapePath, firstHalf);
      final actualSecond = Path.combine(PathOperation.intersect, shapePath, secondHalf);
      
      if (!actualFirst.getBounds().isEmpty && !actualSecond.getBounds().isEmpty) {
        return [actualFirst, actualSecond];
      }
    } catch (e) {
      debugPrint('备用矩形切割方法也失败: $e');
    }
    
    // 如果全部方法失败，返回原始形状和空路径
    return [shapePath, Path()];
  }
  
  // 计算两个路径面积的比例，返回0到1之间的值（1表示完全相等）
  static double calculateAccuracy(Path path1, Path path2) {
    // 使用图形API计算路径面积
    // 注意：这是一个简化方法，实际上计算复杂路径的准确面积可能更复杂
    // 一种方法是光栅化路径并计算像素
    
    // 创建一个虚拟画布和图片
    final PictureRecorder recorder1 = PictureRecorder();
    final Canvas canvas1 = Canvas(recorder1);
    
    // 绘制第一个路径
    canvas1.drawPath(path1, Paint()..color = Colors.black);
    final picture1 = recorder1.endRecording();
    
    // 创建第二个记录器
    final PictureRecorder recorder2 = PictureRecorder();
    final Canvas canvas2 = Canvas(recorder2);
    
    // 绘制第二个路径
    canvas2.drawPath(path2, Paint()..color = Colors.black);
    final picture2 = recorder2.endRecording();
    
    // 计算两个路径占用的像素数量
    // 在实际应用中，您可能需要使用Image类创建图像并分析像素
    
    // 以下是一个简化的面积计算近似值
    // 在实际应用中，您可能需要实现更精确的算法
    final rect1 = path1.getBounds();
    final rect2 = path2.getBounds();
    
    final area1 = rect1.width * rect1.height;
    final area2 = rect2.width * rect2.height;
    
    if (area1 == 0 || area2 == 0) {
      return 0.0; // 避免除以零
    }
    
    // 计算面积比例
    final ratio = area1 < area2 ? area1 / area2 : area2 / area1;
    
    return ratio;
  }
  
  // 一个更准确的面积计算方法，使用蒙特卡洛方法
  static double calculateAreaMoreAccurate(Path path1, Path path2, {int samples = 5000}) {
    // 确定两个路径的总体边界
    final boundingRect = path1.getBounds().expandToInclude(path2.getBounds());
    
    // 如果某个路径很小或为空，返回低精度
    if (path1.getBounds().isEmpty || path2.getBounds().isEmpty) {
      return 0.1; // 返回一个合理的低精度值
    }
    
    // 使用蒙特卡洛方法采样点
    double area1 = 0;
    double area2 = 0;
    
    final random = Random();
    
    // 计算每个路径的实际面积
    for (int i = 0; i < samples; i++) {
      final point = Offset(
        boundingRect.left + random.nextDouble() * boundingRect.width,
        boundingRect.top + random.nextDouble() * boundingRect.height,
      );
      
      if (path1.contains(point)) {
        area1 += 1;
      }
      
      if (path2.contains(point)) {
        area2 += 1;
      }
    }
    
    // 如果两个路径都没有点，返回0.5（中等精度）
    if (area1 < 1 && area2 < 1) {
      return 0.5;
    }
    
    // 路径总面积
    final totalArea = area1 + area2;
    
    // 如果没有有效面积，返回低精度
    if (totalArea < 1) {
      return 0.1;
    }
    
    // 计算两个部分是否接近50/50
    final ratio1 = area1 / totalArea;
    final ratio2 = area2 / totalArea;
    
    // 如果比例接近50/50，返回高精度
    // 计算接近50%的程度（1表示完全相等，0表示完全不等）
    final equalityRatio = 1.0 - (ratio1 - 0.5).abs() * 2;
    
    return equalityRatio;
  }
} 