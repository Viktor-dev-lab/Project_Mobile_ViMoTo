import 'package:flutter/material.dart';

class NeumorphicButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const NeumorphicButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF388E3C).withValues(alpha: 0.5),
              offset: const Offset(5, 5),
              blurRadius: 15,
            ),
            BoxShadow(
              color: const Color(0xFFC8E6C9).withValues(alpha: 0.9),
              offset: const Offset(-5, -5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
