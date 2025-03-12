import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final int animationDelay;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.color = Colors.blue,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: Duration(milliseconds: animationDelay),
      duration: const Duration(milliseconds: 500),
    )
    .slideX(
      begin: 0.2,
      end: 0,
      delay: Duration(milliseconds: animationDelay),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
    );
  }
} 