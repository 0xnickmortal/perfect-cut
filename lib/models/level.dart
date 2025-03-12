import 'shape.dart';

class Level {
  final int id;
  final GameShape shape;
  final int requiredSlices; // 需要切成几块（2或4）
  final double perfectThreshold; // 完美切割的阈值
  final String? backgroundImage; // 背景图片
  
  const Level({
    required this.id,
    required this.shape,
    this.requiredSlices = 2,
    this.perfectThreshold = 0.99,
    this.backgroundImage,
  });
  
  // 克隆关卡，但可以更改某些属性
  Level copyWith({
    int? id,
    GameShape? shape,
    int? requiredSlices,
    double? perfectThreshold,
    String? backgroundImage,
  }) {
    return Level(
      id: id ?? this.id,
      shape: shape ?? this.shape,
      requiredSlices: requiredSlices ?? this.requiredSlices,
      perfectThreshold: perfectThreshold ?? this.perfectThreshold,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }
  
  // 判断切割结果是否"完美"
  bool isPerfectCut(double accuracy) {
    return accuracy >= perfectThreshold;
  }
} 