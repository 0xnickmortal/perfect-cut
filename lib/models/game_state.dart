import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'level.dart';
import 'shape.dart';

class GameState extends ChangeNotifier {
  int _currentLevel = 0;
  int _stars = 0;
  int _perfectCuts = 0;
  bool _soundEnabled = true;
  bool _isEnglish = false; // 默认使用中文
  List<Level> _levels = [];
  List<bool> _unlockedLevels = [];
  
  // Getters
  int get currentLevel => _currentLevel;
  int get stars => _stars;
  int get perfectCuts => _perfectCuts;
  bool get soundEnabled => _soundEnabled;
  bool get isEnglish => _isEnglish;
  List<Level> get levels => _levels;
  List<bool> get unlockedLevels => _unlockedLevels;
  
  GameState() {
    _initLevels();
    _loadGameState();
  }
  
  void _initLevels() {
    // 创建基本形状
    _levels = [
      // 第1关 - 矩形
      Level(
        id: 0,
        shape: GameShape.rectangle(width: 200, height: 100, color: Colors.blue),
        requiredSlices: 2,
        perfectThreshold: 0.99, // 99%相等算"完美"
      ),
      // 第2关 - 正方形
      Level(
        id: 1,
        shape: GameShape.rectangle(width: 150, height: 150, color: Colors.purple),
        requiredSlices: 2,
        perfectThreshold: 0.99,
      ),
      // 第3关 - 圆形
      Level(
        id: 2,
        shape: GameShape.circle(radius: 100, color: Colors.green),
        requiredSlices: 2,
        perfectThreshold: 0.985,
      ),
      // 第4关 - 三角形
      Level(
        id: 3,
        shape: GameShape.triangle(size: 200, color: Colors.orange),
        requiredSlices: 2,
        perfectThreshold: 0.985,
      ),
      // 第5关 - 椭圆形
      Level(
        id: 4,
        shape: GameShape.oval(width: 200, height: 120, color: Colors.purple),
        requiredSlices: 2,
        perfectThreshold: 0.98,
      ),
      // 第6关 - 五角星
      Level(
        id: 5,
        shape: GameShape.star(size: 200, points: 5, color: Colors.amber),
        requiredSlices: 2,
        perfectThreshold: 0.975,
      ),
      // 第7关 - 六边形
      Level(
        id: 6,
        shape: GameShape.polygon(radius: 100, sides: 6, color: Colors.teal),
        requiredSlices: 2,
        perfectThreshold: 0.97,
      ),
      // 第8关 - 心形
      Level(
        id: 7,
        shape: GameShape.heart(size: 220, color: Colors.redAccent),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第9关 - 苹果
      Level(
        id: 8,
        shape: GameShape.apple(size: 200, color: Colors.red),
        requiredSlices: 2,
        perfectThreshold: 0.96,
      ),
      // 第10关 - 水滴
      Level(
        id: 9,
        shape: GameShape.drop(size: 200, color: const Color(0xFF81D4FA)),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第11关 - 叶子
      Level(
        id: 10,
        shape: GameShape.leaf(size: 220, color: Colors.green),
        requiredSlices: 2,
        perfectThreshold: 0.96,
      ),
      // 第12关 - 钻石
      Level(
        id: 11,
        shape: GameShape.diamond(size: 200, color: const Color(0xFF64B5F6)),
        requiredSlices: 2,
        perfectThreshold: 0.97,
      ),
      // 第13关 - 八角星
      Level(
        id: 12,
        shape: GameShape.star(size: 200, points: 8, color: Colors.deepPurple),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第14关 - 八边形
      Level(
        id: 13,
        shape: GameShape.polygon(radius: 100, sides: 8, color: Colors.indigo),
        requiredSlices: 2,
        perfectThreshold: 0.975,
      ),
      // 第15关 - 菱形
      Level(
        id: 14,
        shape: GameShape.polygon(radius: 100, sides: 4, color: Colors.pink),
        requiredSlices: 2,
        perfectThreshold: 0.98,
      ),
      // 第16关 - 大心形
      Level(
        id: 15,
        shape: GameShape.heart(size: 240, color: Colors.redAccent),
        requiredSlices: 2,
        perfectThreshold: 0.96,
      ),
      // 第17关 - 复杂星形
      Level(
        id: 16,
        shape: GameShape.star(size: 240, points: 12, color: const Color(0xFFC62828)),
        requiredSlices: 2,
        perfectThreshold: 0.96,
      ),
      // 第18关 - SVG矢量苹果
      Level(
        id: 17,
        shape: GameShape.fromSvg(
          svgPath: "M 878 697C 873 711 868 725 862 739C 849 770 832 799 814 826C 788 862 767 887 751 901C 727 924 700 936 671 936C 651 936 626 930 597 919C 568 907 542 901 518 901C 492 901 465 907 436 919C 407 930 383 937 365 937C 338 938 310 926 283 901C 266 886 244 860 218 823C 190 784 167 738 149 686C 130 630 120 576 120 523C 120 463 133 411 159 367C 180 332 207 304 241 284C 275 264 312 253 352 253C 374 253 402 259 438 273C 473 286 496 293 506 293C 513 293 538 285 581 269C 621 255 656 249 683 251C 759 257 816 287 854 341C 786 382 753 439 753 513C 754 570 775 618 816 656C 834 674 855 687 878 697 M 688 55C 688 100 672 142 639 181C 600 227 552 254 500 250C 499 245 499 239 499 233C 499 190 518 143 551 106C 568 87 589 71 615 58C 640 45 665 38 688 37C 688 43 688 49 688 55",
          width: 240,
          height: 240,
          color: Colors.red,
        ),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第19关 - 香蕉
      Level(
        id: 18,
        shape: GameShape.fromSvg(
          svgPath: "M8.64 223.95c0 0 143.47 3.43 185.78-181.81 2.67-11.7-1.23-20.15 1.32-33.15h16.29s-3.14 17.25 1.1 30.85c21.39 68.7-4.18 242.34-204.23 196.59l-0.25-12.48z",
          width: 450,
          height: 450,
          color: const Color(0xFFF7C562), // 香蕉黄
        ),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第20关 - 咖啡杯
      Level(
        id: 19,
        shape: GameShape.fromSvg(
          svgPath: "M60 40 L240 40 L220 200 Q140 220 80 200 L60 40 M240 60 Q280 80 280 120 Q280 160 240 180",
          width: 450,
          height: 360,
          color: const Color(0xFF8D6E63), // 咖啡棕
        ),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
      // 第21关 - 汽车
      Level(
        id: 20,
        shape: GameShape.fromSvg(
          svgPath: "M40 140 L40 180 L220 180 L220 140 Q180 100 80 100 L40 140 M60 180 Q60 200 80 200 Q100 200 100 180 M160 180 Q160 200 180 200 Q200 200 200 180",
          width: 650,
          height: 500,
          color: const Color(0xFFE53935), // 汽车红
        ),
        requiredSlices: 2,
        perfectThreshold: 0.965,
      ),
    ];
    
    // 初始化解锁状态，第一关临时解锁用于测试
    _unlockedLevels = List.generate(_levels.length, (index) => 
      index == 0
    );
  }
  
  Future<void> _loadGameState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentLevel = prefs.getInt('currentLevel') ?? 0;
      _stars = prefs.getInt('stars') ?? 0;
      _perfectCuts = prefs.getInt('perfectCuts') ?? 0;
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _isEnglish = prefs.getBool('isEnglish') ?? false; // 加载语言设置
      
      // 加载解锁的关卡
      List<String>? unlockedList = prefs.getStringList('unlockedLevels');
      if (unlockedList != null) {
        _unlockedLevels = List.generate(_levels.length, (index) => 
          unlockedList.contains(index.toString()));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载游戏状态时出错: $e');
    }
  }
  
  Future<void> _saveGameState() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentLevel', _currentLevel);
      await prefs.setInt('stars', _stars);
      await prefs.setInt('perfectCuts', _perfectCuts);
      await prefs.setBool('soundEnabled', _soundEnabled);
      await prefs.setBool('isEnglish', _isEnglish); // 保存语言设置
      
      // 保存解锁的关卡
      List<String> unlockedList = [];
      for (int i = 0; i < _unlockedLevels.length; i++) {
        if (_unlockedLevels[i]) {
          unlockedList.add(i.toString());
        }
      }
      await prefs.setStringList('unlockedLevels', unlockedList);
    } catch (e) {
      debugPrint('保存游戏状态时出错: $e');
    }
  }
  
  // 切换声音
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveGameState();
    notifyListeners();
  }
  
  // 设置当前关卡
  void setCurrentLevel(int level) {
    if (level >= 0 && level < _levels.length) {
      _currentLevel = level;
      _saveGameState();
      notifyListeners();
    }
  }
  
  // 解锁下一关
  void unlockNextLevel() {
    if (_currentLevel + 1 < _levels.length) {
      _unlockedLevels[_currentLevel + 1] = true;
      _saveGameState();
      notifyListeners();
    }
  }
  
  // 根据切割精度完成当前关卡
  void completeLevel(double accuracy) {
    // 计算星星数量 (1-3)
    int earnedStars = 1; // 至少1颗星
    
    if (accuracy >= 0.9) {
      earnedStars = 2;
    }
    
    if (accuracy >= _levels[_currentLevel].perfectThreshold) {
      earnedStars = 3;
      _perfectCuts++;
    }
    
    _stars += earnedStars;
    
    // 解锁下一关
    unlockNextLevel();
    
    // 保存游戏状态
    _saveGameState();
    notifyListeners();
    
    return;
  }
  
  // 重置游戏进度
  void resetProgress() {
    _currentLevel = 0;
    _stars = 0;
    _perfectCuts = 0;
    _unlockedLevels = List.generate(_levels.length, (index) => 
      index == 0
    );
    _saveGameState();
    notifyListeners();
  }
  
  // 切换语言
  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    _saveGameState();
    notifyListeners();
  }
} 