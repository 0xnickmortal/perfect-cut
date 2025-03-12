import 'dart:math';
import 'package:flutter/material.dart';

// Offset扩展方法
extension OffsetExtensions on Offset {
  // 标准化向量（单位向量）
  Offset normalize() {
    final magnitude = distance;
    if (magnitude == 0) {
      return Offset.zero;
    }
    return Offset(dx / magnitude, dy / magnitude);
  }
  
  // 获取向量的长度
  double get length => distance;
  
  // 垂直于当前向量的向量（顺时针旋转90度）
  Offset get perpendicular => Offset(-dy, dx);
} 