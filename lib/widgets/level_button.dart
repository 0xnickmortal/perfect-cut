import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/translations.dart';

class LevelButton extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final int animationDelay;
  final bool isEnglish;

  const LevelButton({
    super.key,
    required this.level,
    required this.isUnlocked,
    this.onTap,
    this.animationDelay = 0,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked 
              ? Colors.blue 
              : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (isUnlocked ? Colors.blue : Colors.grey).withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 锁图标（仅在未解锁时显示）
            if (!isUnlocked)
              Tooltip(
                message: tr('locked', isEnglish),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 30,
                ),
              ),
            
            // 关卡号
            Text(
              '$level',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // 未解锁时文字变暗
                shadows: isUnlocked
                    ? [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: Duration(milliseconds: animationDelay),
      duration: const Duration(milliseconds: 300),
    )
    .scale(
      delay: Duration(milliseconds: animationDelay),
      duration: const Duration(milliseconds: 300),
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
    );
  }
} 